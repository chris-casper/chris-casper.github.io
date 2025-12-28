---
title: "Nebra Cell Modem Setup and Config"
excerpt: "Low cost high power LoRA Mesh networking"
last_modified_at: 2025-08-23 20:00:00
tags:
  - Meshtastic
  - LoRA
  - crypto
---


![Meshtastic Pi](/images/posts/nebra/nebra-dual.jpg)

### Hardware Install

This instance is a Hooper ZebraHat and a prototype USB meshtastic radio that's picked up by default. You'll have to adjust each. The script does create two folders under /etc/meshtasticd to make life easier. It works pretty much exactly like the base folder. 

You shouldn't need to adjust the systemctl unit files but you can do so by finding the files with ls /etc/systemd/system/meshtasticd*

This was developed from [platfrastructure](https://platfrastructure.life/post/meshtasticd-multi/)

### Setup Script

This is brand new and I'm still working through the config. Please reach out if you run into any issues.

```shell
#!/usr/bin/env bash
set -euo pipefail

# --- Instances ---
ZEBRA_NAME="zebra"
USB_NAME="usb"

ZEBRA_PORT="4403"
USB_PORT="4404"

BASE_CFG="/etc/meshtasticd/config.yaml"

ZEBRA_DIR="/etc/meshtasticd/${ZEBRA_NAME}"
USB_DIR="/etc/meshtasticd/${USB_NAME}"

ZEBRA_CFG="${ZEBRA_DIR}/config.yaml"
USB_CFG="${USB_DIR}/config.yaml"

ZEBRA_CFGD="${ZEBRA_DIR}/config.d"
USB_CFGD="${USB_DIR}/config.d"

ZEBRA_YAML="${ZEBRA_CFGD}/ZebraHat.yaml"
ZEBRA_YAML_URL="https://raw.githubusercontent.com/wehooper4/Meshtastic-Hardware/refs/heads/main/ZebraHAT/ZebraHat.yaml"

ZEBRA_FSDIR="/var/lib/meshtasticd-${ZEBRA_NAME}"
USB_FSDIR="/var/lib/meshtasticd-${USB_NAME}"

ZEBRA_UNIT="/etc/systemd/system/meshtasticd-${ZEBRA_NAME}.service"
USB_UNIT="/etc/systemd/system/meshtasticd-${USB_NAME}.service"

MESHTASTICD_BIN="/usr/bin/meshtasticd"

# --- Helper: generate random MAC like AA:BB:CC:DD:EE:FF (random last 3 bytes) ---
rand_mac() {
  local r
  r="$(openssl rand -hex 3)"              # 6 hex chars
  # Format: AA:BB:CC:xx:yy:zz
  printf "AA:BB:CC:%s:%s:%s\n" "${r:0:2}" "${r:2:2}" "${r:4:2}"
}

# --- Helper: patch config.yaml (YAML indentation safe) ---
patch_config() {
  local cfg="$1"
  local cfgdir="$2"
  local mac="$3"

  # 1) Point ConfigDirectory at instance-specific config.d (keep YAML indentation)
  #    Replace any existing ConfigDirectory line (commented or not).
  if grep -qE '^[[:space:]]*ConfigDirectory:' "$cfg"; then
    sed -i -E "s|^[[:space:]]*ConfigDirectory:[[:space:]]*.*$|  ConfigDirectory: ${cfgdir}/|" "$cfg"
  else
    # Insert after "General:" line
    awk -v cfgdir="${cfgdir}" '
      {print}
      /^General:[[:space:]]*$/ {print "  ConfigDirectory: " cfgdir "/"}
    ' "$cfg" > "${cfg}.tmp" && mv "${cfg}.tmp" "$cfg"
  fi

  # 2) Comment out MACAddressSource: eth0 with YAML-safe indentation:
  #    "  MACAddressSource: eth0"  -> "  # MACAddressSource: eth0"
  #    If it's already commented, leave it alone.
  sed -i -E 's/^([[:space:]]*)MACAddressSource:[[:space:]]*eth0/\1# MACAddressSource: eth0/' "$cfg"

  # 3) Ensure MACAddress is set with EXACTLY two leading spaces:
  #    Replace existing commented/uncommented MACAddress line, anywhere.
  if grep -qE '^[[:space:]]*#?[[:space:]]*MACAddress:[[:space:]]*' "$cfg"; then
    # Normalize to exactly "  MACAddress: <mac>"
    sed -i -E "s|^[[:space:]]*#?[[:space:]]*MACAddress:[[:space:]]*.*$|  MACAddress: ${mac}|" "$cfg"
  else
    # Insert after "General:" line
    awk -v mac="${mac}" '
      {print}
      /^General:[[:space:]]*$/ {print "  MACAddress: " mac}
    ' "$cfg" > "${cfg}.tmp" && mv "${cfg}.tmp" "$cfg"
  fi
}

# --- Preconditions ---
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)."
  exit 1
fi

if [[ ! -f "$BASE_CFG" ]]; then
  echo "ERROR: Base config not found at $BASE_CFG"
  exit 1
fi

if [[ ! -x "$MESHTASTICD_BIN" ]]; then
  echo "ERROR: meshtasticd not found/executable at $MESHTASTICD_BIN"
  exit 1
fi

# --- STOP/DISABLE ORIGINAL SINGLE-INSTANCE SERVICE (no prompt) ---
if systemctl list-unit-files | grep -qE '^meshtasticd\.service'; then
  echo "Stopping/disabling original meshtasticd.service ..."
  systemctl stop meshtasticd.service || true
  systemctl disable meshtasticd.service || true
  systemctl mask meshtasticd.service || true
fi

# --- Create directories ---
mkdir -p "$ZEBRA_CFGD" "$USB_CFGD"
mkdir -p "$ZEBRA_FSDIR" "$USB_FSDIR"

# --- Copy base config.yaml into each instance directory ---
cp -f "$BASE_CFG" "$ZEBRA_CFG"
cp -f "$BASE_CFG" "$USB_CFG"

# --- Download ZebraHat.yaml into zebra instance config.d ---
wget -q -O "$ZEBRA_YAML" "$ZEBRA_YAML_URL"

# --- Patch both instance configs ---
ZEBRA_MAC="$(rand_mac)"
USB_MAC="$(rand_mac)"

patch_config "$ZEBRA_CFG" "$ZEBRA_CFGD" "$ZEBRA_MAC"
patch_config "$USB_CFG" "$USB_CFGD" "$USB_MAC"

# --- Determine whether meshtasticd user exists ---
USE_USERGROUP="yes"
if ! id meshtasticd >/dev/null 2>&1; then
  USE_USERGROUP="no"
  echo "WARN: user 'meshtasticd' not found; unit files will run as root."
fi

# --- Write unit files (multi-instance pattern: --port, --config, --fsdir) ---
cat > "$ZEBRA_UNIT" <<EOF
[Unit]
Description=Meshtastic Native Daemon (${ZEBRA_NAME})
After=network-online.target
StartLimitInterval=200
StartLimitBurst=5

[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
Type=simple
EOF

if [[ "$USE_USERGROUP" == "yes" ]]; then
cat >> "$ZEBRA_UNIT" <<EOF
User=meshtasticd
Group=meshtasticd
EOF
fi

cat >> "$ZEBRA_UNIT" <<EOF
ExecStart=${MESHTASTICD_BIN} --port ${ZEBRA_PORT} --config ${ZEBRA_CFG} --fsdir ${ZEBRA_FSDIR}
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

cat > "$USB_UNIT" <<EOF
[Unit]
Description=Meshtastic Native Daemon (${USB_NAME})
After=network-online.target
StartLimitInterval=200
StartLimitBurst=5

[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
Type=simple
EOF

if [[ "$USE_USERGROUP" == "yes" ]]; then
cat >> "$USB_UNIT" <<EOF
User=meshtasticd
Group=meshtasticd
EOF
fi

cat >> "$USB_UNIT" <<EOF
ExecStart=${MESHTASTICD_BIN} --port ${USB_PORT} --config ${USB_CFG} --fsdir ${USB_FSDIR}
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# --- Permissions (fix /var/lib/meshtasticd-zebra and friends) ---
# Ensure sane modes regardless of whether the user/group exists.
chmod 0755 "$ZEBRA_DIR" "$USB_DIR" "$ZEBRA_CFGD" "$USB_CFGD" || true
chmod 0644 "$ZEBRA_CFG" "$USB_CFG" "$ZEBRA_YAML" || true
chmod 0750 "$ZEBRA_FSDIR" "$USB_FSDIR" || true

if [[ "$USE_USERGROUP" == "yes" ]]; then
  chown -R meshtasticd:meshtasticd "$ZEBRA_DIR" "$USB_DIR" || true
  chown -R meshtasticd:meshtasticd "$ZEBRA_FSDIR" "$USB_FSDIR" || true
fi

# --- Enable and start new instances ---
systemctl daemon-reload
systemctl enable --now "meshtasticd-${ZEBRA_NAME}.service"
systemctl enable --now "meshtasticd-${USB_NAME}.service"

echo
echo "✅ Created and started:"
echo "  meshtasticd-${ZEBRA_NAME}.service (port ${ZEBRA_PORT})"
echo "  meshtasticd-${USB_NAME}.service   (port ${USB_PORT})"
echo
echo "✅ Configs:"
echo "  $ZEBRA_CFG  (MACAddress: ${ZEBRA_MAC}, ConfigDirectory: ${ZEBRA_CFGD}/)"
echo "  $USB_CFG    (MACAddress: ${USB_MAC},   ConfigDirectory: ${USB_CFGD}/)"
echo
echo "✅ ZebraHat.yaml:"
echo "  $ZEBRA_YAML"
echo
echo "Check status/logs:"
echo "  systemctl status meshtasticd-${ZEBRA_NAME}.service"
echo "  systemctl status meshtasticd-${USB_NAME}.service"
echo "  journalctl -u meshtasticd-${ZEBRA_NAME}.service -f"
echo "  journalctl -u meshtasticd-${USB_NAME}.service -f"

```

### File Permissions

You may need to update file permissions.

```shell

sudo chown -R meshtasticd:meshtasticd /var/lib/meshtasticd-zebra
sudo chown -R meshtasticd:meshtasticd /var/lib/meshtasticd-usb
sudo chmod 750 /var/lib/meshtasticd-zebra
sudo chmod 750 /var/lib/meshtasticd-usb
sudo find /var/lib/meshtasticd-zebra -type d -exec chmod 750 {} \;
sudo find /var/lib/meshtasticd-usb   -type d -exec chmod 750 {} \;

```


### Config

Command line should make life easier. But you have to do them one by one, the cli is slow and clunky. 

```shell
meshtastic --host localhost:4403 --set lora.region "US"
meshtastic --host localhost:4403 --set-owner "SUSQ VAL PA Mesh - Radio 1"
meshtastic --host localhost:4403 --set-owner-short "SVMI"

meshtastic --host localhost:4404 --set lora.region "US"
meshtastic --host localhost:4404 --set-owner "SUSQ VAL PA Mesh - Radio 2"
meshtastic --host localhost:4404 --set-owner-short "SVMI"

sudo systemctl restart meshtasticd-zebra
sudo systemctl restart meshtasticd-usb

```

### Troubleshooting


```shell

journalctl -u meshtasticd-usb.service
journalctl -u meshtasticd-zebra.service

```