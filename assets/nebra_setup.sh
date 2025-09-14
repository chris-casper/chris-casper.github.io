#!/usr/bin/env bash
set -euo pipefail

# =========================
# 
# REMEMBER TO DO AFTER REBOOT : sudo tailscale up
#
# =========================

# ************ THIS IS STILL IN ALPHA DEVELOPMENT - DO NOT USE ************

# =========================
# nebra_setup.sh 
#
# Linux Meshtasticd Setup Script - Optimized for Nebra Nodes
# Written by Chris Casper
#
# v0 - 2025.09.11 - initial
#
# TODO:
# - add non-Hooper hats
# - testing/dry runs
# - verify can be run multiple times to change config?
# - redo update to make sure doesn't hang on questions
# - config.yaml default changes
# - Hat yaml default changes
# - list sensors?
#
# =========================

# =========================
# Defaults (can be overridden by env or CLI flags)
# =========================
GPS_NEO6M="${GPS_NEO6M:-no}"                # yes|no
NEBRA_HAT="${NEBRA_HAT:-2w}"                # 1w|2w
WIFI_MODE="${WIFI_MODE:-stock}"             # stock|ap
AP_SSID="${AP_SSID:-NebraAP}"
AP_PASS="${AP_PASS:-ChangeMe123}"
AP_CHANNEL="${AP_CHANNEL:-6}"
AP_INTERFACE="${AP_INTERFACE:-wlan0}"
SETUP_SDR="${SETUP_SDR:-no}"                # yes|no
BLACKLIST_OLD_SDR="${BLACKLIST_OLD_SDR:-no}"# yes|no  (blacklist dvb modules)
INSTALL_TAILSCALE="${INSTALL_TAILSCALE:-no}"# yes|no
REBOOT_AT_END="${REBOOT_AT_END:-yes}"       # yes|no

# =========================
# Parse CLI args
# =========================
usage() {
  cat <<'USAGE'
  
Usage: ./nebra_setup.sh [options]

Options (all also available via env vars shown in [default]):
  --gps-neo6m {yes|no}            [no]   Enable Neo-6M gpsd + chrony integration
  --hat {1w|2w}                   [2w]   Choose NebraHat profile to download/configure
  --wifi {stock|ap}               [stock]	Keep stock Wi-Fi driver or switch to AP driver + hostapd/dnsmasq
  --ap-ssid SSID                  [NebraAP]	Nebra hosted WiFi network
  --ap-pass PASS                  [ChangeMe123]	Password for Nebra WiFi AP
  --ap-channel N                  [6]			Channel for Nebra WiFi AP
  --ap-iface IFACE                [wlan0]		Interface Name for Nebra WiFi AP
  --sdr {yes|no}                  [no]   Install rtl-sdr tools + udev rule
  --blacklist-sdr {yes|no}        [no]   Blacklist default dvb_usb_rtl28xxu/rtl2832/rtl2830 driver
  --tailscale {yes|no}            [no]   Install Tailscale for remote access
  --reboot {yes|no}               [yes]  Reboot at the end if required
  -h|--help                              Show this help

Examples:
  GPS_NEO6M=yes NEBRA_HAT=1w WIFI_MODE=ap AP_SSID=KD3BQB-AP AP_PASS='StrongPass!' ./nebra_setup.sh
  ./nebra_setup.sh --hat 2w --wifi ap --ap-ssid MyAP --ap-pass secret --sdr yes --blacklist-sdr yes --tailscale yes
  
USAGE
}

# Argument handling
while [[ $# -gt 0 ]]; do
  case "$1" in
    --gps-neo6m) GPS_NEO6M="${2}"; shift 2 ;;
    --hat) NEBRA_HAT="${2,,}"; shift 2 ;;
    --wifi) WIFI_MODE="${2,,}"; shift 2 ;;
    --ap-ssid) AP_SSID="${2}"; shift 2 ;;
    --ap-pass) AP_PASS="${2}"; shift 2 ;;
    --ap-channel) AP_CHANNEL="${2}"; shift 2 ;;
    --ap-iface) AP_INTERFACE="${2}"; shift 2 ;;
    --sdr) SETUP_SDR="${2}"; shift 2 ;;
    --blacklist-sdr) BLACKLIST_OLD_SDR="${2}"; shift 2 ;;
    --tailscale) INSTALL_TAILSCALE="${2}"; shift 2 ;;
    --reboot) REBOOT_AT_END="${2}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

# Require sudo
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo)."
  exit 1
fi

# Utilities
# 
# - basic version, needs work
apt_update_once() {
  if [[ ! -f /tmp/.apt_updated ]]; then
    apt-get update -y
    touch /tmp/.apt_updated
  fi
}

needs_reboot="no"

# =========================
# Meshtastic repo + install 
# =========================
install_meshtastic() {
  echo ">>> Installing Meshtasticd and prerequisites..."
  apt_update_once
  apt-get install -y curl gpg sed

  # Add Meshtastic beta repo (Debian 12)
  echo "deb http://download.opensuse.org/repositories/network:/Meshtastic:/beta/Debian_12/ /" \
    > /etc/apt/sources.list.d/network:Meshtastic:beta.list

  curl -fsSL https://download.opensuse.org/repositories/network:Meshtastic:beta/Debian_12/Release.key \
    | gpg --dearmor > /etc/apt/trusted.gpg.d/network_Meshtastic_beta.gpg

  apt-get update -y
  apt-get install -y Meshtasticd
}

# =========================
# Enable SPI + insert dtoverlay=spi0-0cs 
# =========================
enable_spi_and_overlay() {
  local cfg="/boot/firmware/config.txt"
  echo ">>> Enabling SPI and ensuring dtoverlay=spi0-0cs in ${cfg}"

  # Ensure file exists
  touch "${cfg}"

  # Enable SPI
  if command -v raspi-config >/dev/null 2>&1; then
    raspi-config nonint set_config_var dtparam=spi on "${cfg}" || true
  fi

  # Force dtparam=spi=on if not present
  if ! grep -Eq '^\s*dtparam=spi=on' "${cfg}"; then
    echo "dtparam=spi=on" >> "${cfg}"
  fi

  # Ensure dtoverlay=spi0-0cs present
  if ! grep -Eq '^\s*dtoverlay=spi0-0cs' "${cfg}"; then
    sed -i '/^\s*dtparam=spi=on/a dtoverlay=spi0-0cs' "${cfg}"
  fi

  # test this section, a lot
  needs_reboot="yes"
}

# =========================
# NebraHat config 
# =========================
configure_nebra_hat() {
  echo ">>> Configuring NebraHat (${NEBRA_HAT^^}) profile..."
  mkdir -p /etc/Meshtasticd/config.d

  local base_url="https://github.com/wehooper4/Meshtastic-Hardware/raw/refs/heads/main/NebraHat"
  case "${NEBRA_HAT}" in
    1w)
      curl -fL "${base_url}/NebraHat_1W.yaml" -o /etc/Meshtasticd/config.d/NebraHat_1W.yaml
      ;;
    2w)
      curl -fL "${base_url}/NebraHat_2W.yaml" -o /etc/Meshtasticd/config.d/NebraHat_2W.yaml
      ;;
    *)
      echo "Unknown NEBRA_HAT value '${NEBRA_HAT}'. Use 1w or 2w."
      exit 1
      ;;
  esac
  # do nebrahat_Xw.yaml default changes here, too tired to do right now

  # Ensure base config exists
  touch /etc/Meshtasticd/config.yaml
  # Need the default config.yaml changes here
  # remember to include gps: in gps section below

  systemctl enable Meshtasticd
  systemctl restart Meshtasticd || true
}

# =========================
# I2C tools 
# =========================
install_i2c_tools() {
  echo ">>> Installing I2C tools (optional sensor discovery)..."
  apt_update_once
  apt-get install -y i2c-tools
  # list existing sensors?
}

# =========================
# Wi-Fi: keep stock or install AP driver + optional AP stack
# AP stack added for convenience
# =========================
setup_wifi() {
  if [[ "${WIFI_MODE}" == "stock" ]]; then
    echo ">>> Keeping stock Wi-Fi driver."
    return 0
  fi

  echo ">>> Switching to rtl8188eus driver for AP mode..."
  apt_update_once
  apt-get install -y wget dkms

  # Fetch prebuilt deb from referenced repo
  # - cache somewhere just in case?
  local tmpdeb="/root/rtl8188eus_1.0-1_arm64.deb"
  wget -O "${tmpdeb}" "https://github.com/wehooper4/Meshtastic-Hardware/raw/refs/heads/main/NebraHat/nebraAP/rtl8188eus_1.0-1_arm64.deb"
  dpkg -i "${tmpdeb}" || apt-get -f install -y

  # Blacklist old module and ensure 8188eu loads
  # - had issues here
  echo "blacklist rtl8xxxu" > /etc/modprobe.d/rtl8xxxu.conf
  modprobe 8188eu || true

  needs_reboot="yes"

  # Optional AP stack
  echo ">>> Installing hostapd + dnsmasq for AP mode..."
  apt_update_once
  apt-get install -y hostapd dnsmasq

  # Stop for config stage
  systemctl stop hostapd || true
  systemctl stop dnsmasq || true

  # Configure a simple AP on ${AP_INTERFACE}
  # - test these a lot
  cat > /etc/hostapd/hostapd.conf <<EOF
interface=${AP_INTERFACE}
driver=nl80211
ssid=${AP_SSID}
hw_mode=g
channel=${AP_CHANNEL}
ieee80211n=1
wmm_enabled=1
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=${AP_PASS}
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
EOF

  sed -i 's|#DAEMON_CONF="".*|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

  # Static IP for AP side
  cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak || true
  if ! grep -q "interface ${AP_INTERFACE}" /etc/dhcpcd.conf 2>/dev/null; then
    cat >> /etc/dhcpcd.conf <<EOF

interface ${AP_INTERFACE}
static ip_address=192.168.50.1/24
nohook wpa_supplicant
EOF
  fi

  # dnsmasq for DHCP
  mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak || true
  cat > /etc/dnsmasq.conf <<EOF
interface=${AP_INTERFACE}
dhcp-range=192.168.50.100,192.168.50.200,12h
domain-needed
bogus-priv
EOF

  systemctl enable hostapd dnsmasq
}

# =========================
# SDR support (rtl-sdr + udev rule) and optional blacklist of DVB drivers
# =========================
setup_sdr() {
  if [[ "${SETUP_SDR}" != "yes" && "${BLACKLIST_OLD_SDR}" != "yes" ]]; then
    return 0
  fi

  if [[ "${SETUP_SDR}" == "yes" ]]; then
    echo ">>> Installing rtl-sdr + rtl-433 + soapyremote-server..."
    apt_update_once
    apt-get install -y rtl-sdr rtl-433 soapyremote-server

    # permissive udev rule for Realtek 0bda:2838
    if [[ -f /lib/udev/rules.d/60-rtl-sdr.rules ]]; then
      cp /lib/udev/rules.d/60-rtl-sdr.rules /etc/udev/rules.d/
    else
      cat > /etc/udev/rules.d/20-rtl-sdr.rules <<'EOF'
# NooElec NESDR / RTL2832U SDR dongles
SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE="0666", GROUP="plugdev"
EOF
    fi
    groupadd -f plugdev
    udevadm control --reload-rules
    udevadm trigger
  fi

  # should I make this default yes?
  if [[ "${BLACKLIST_OLD_SDR}" == "yes" ]]; then
    echo ">>> Blacklisting DVB SDR kernel modules..."
    cat > /etc/modprobe.d/blacklist-rtlsdr.conf <<'EOF'
blacklist dvb_usb_rtl28xxu
blacklist rtl2832
blacklist rtl2830
EOF
    update-initramfs -u
    needs_reboot="yes"
  fi
}

# =========================
# Neo-6M GPS + gpsd + chrony (clean, minimal setup)
# =========================
setup_gps_neo6m() {
  if [[ "${GPS_NEO6M}" != "yes" ]]; then
    return 0
  fi
  echo ">>> Setting up gpsd + chrony for Neo-6M..."

  # remove pps-tools? You need to manually wire PPS pin, how many will?
  apt_update_once
  apt-get install -y gpsd gpsd-clients chrony pps-tools

  # Enable UART (ttyAMA0) if not already. Many Nebra builds wire GPS to UART0.
  local cfg="/boot/firmware/config.txt"
  touch "${cfg}"
  if ! grep -Eq '^\s*enable_uart=1' "${cfg}"; then
    echo "enable_uart=1" >> "${cfg}"
    needs_reboot="yes"
  fi

  # gpsd default: point at /dev/ttyAMA0 
  # Set to serial1 by default, but can switch over by commenting
  sed -i 's|^#\?START_DAEMON=.*|START_DAEMON="true"|' /etc/default/gpsd
  sed -i 's|^#\?GPSD_OPTIONS=.*|GPSD_OPTIONS="-n"|' /etc/default/gpsd
#  sed -i 's|^#\?DEVICES=.*|DEVICES="/dev/ttyAMA0"|' /etc/default/gpsd
  sed -i 's|^#\?DEVICES=.*|DEVICES="/dev/serial1"|' /etc/default/gpsd
  sed -i 's|^#\?USBAUTO=.*|USBAUTO="true"|' /etc/default/gpsd

  systemctl enable gpsd
  systemctl restart gpsd || true

  # Minimal chrony config to use gpsd SHM(0); add PPS if wired later
  # No offsets, adjust if needed
  if ! grep -q "refclock SHM 0" /etc/chrony/chrony.conf; then
    cat >> /etc/chrony/chrony.conf <<'EOF'

# GPS via gpsd shared memory
refclock SHM 0 refid GPS precision 1e-1 poll 4 dpoll -2
# If you later enable PPS (e.g., /dev/pps0 via pps_gpio), add:
#refclock PPS /dev/pps0 refid PPS lock GPS
EOF
  fi
  systemctl restart chrony || true
}

# =========================
# Tailscale (last)
# =========================
install_tailscale() {
  if [[ "${INSTALL_TAILSCALE}" != "yes" ]]; then
    return 0
  fi
  echo ">>> Installing Tailscale..."
  apt_update_once
  apt-get install -y curl gnupg

  curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg \
    | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
  curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list \
    | tee /etc/apt/sources.list.d/tailscale.list >/dev/null

  apt-get update -y
  apt-get install -y tailscale
  systemctl enable --now tailscaled
  echo ">>> Run 'tailscale up' to log in with your account and connect."
}

# =========================
# Main
# =========================

install_meshtastic
enable_spi_and_overlay
configure_nebra_hat
install_i2c_tools
setup_wifi
setup_sdr
setup_gps_neo6m
install_tailscale

echo ">>> All selected steps completed."
echo ">>> All systems online"
if [[ "${needs_reboot}" == "yes" && "${REBOOT_AT_END}" == "yes" ]]; then
  echo ">>> Rebooting in 5 seconds to apply kernel/firmware changes (SPI/Wi-Fi/GPS)..."
  sleep 5
  systemctl reboot
else
  echo ">>> Reboot recommended: ${needs_reboot}. Auto-reboot set to: ${REBOOT_AT_END}."
fi
