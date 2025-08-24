---
title: "Nebra Cell Modem Setup and Config"
excerpt: "Low cost high power LoRA Mesh networking"
last_modified_at: 2025-08-23 20:00:00
tags:
  - Meshtastic
  - LoRA
  - crypto
---


![Meshtastic Pi](/images/posts/nebra/nebra-case.jpg)

### Nebra Cell Modem

After picking up a couple Nebra units, I read the manuals and specs sheets. And noticed the official optional cell modem. The original MSRP was insanely high but now is on eBay for $20. The model is the Quectel EG25-G Mini PCIe 4G Mobile Broadband Card w/ Antennas.

The kit comes with:
- Quectel EG25-G Mini PCIe card
- 2x LTE antenna
- 2x ipex to N bulkhead

CAD model is available [here](https://www.digikey.com/en/models/13278349).

Bands are:
- LTE-FDD	B1, B2, B3, B4, B5, B7, B8, B12, B13, B18, B19, B20, B25, B26, B28
- LTE-TDD	B38, B39, B40, B41
- WCDMA	B1, B2, B4, B5, B6, B8, B19
- GSM	850, 900, 1800, 1900 MHz

Uses 3x IPEX-1 connectors : LTE main antenna + LTE diversity antenna + GNSS antenna)


It can do LTE, UMTS/HSPA+, and GSM/GPRS/EDGE. It can do MIMO for 150Mbps down and 50Mbps up. It uses multi-constellation Qualcomm IZat GNSS Gen8C Lite that supports GPS, GLONASS, BDS, Galileo and QZSS. SMS supports MT, MO, CB, Text, PDU. It can do voice calls, which has interesting possibilities. 


### Hardware Install

- Insert SIM card - you'll need it even just for GPS to work reliably. I don't think it even needs to have service
- Remove metal clip closer to the edge of the system board
- Slide in the Mini PCIe at 30-45 degrees into the connector side
- Press down to flat, there are two spring loaded clips that will hold it in position
- Connect MAIN and GNSS ipex bulkheads and antennas. Leave DIV empty. 

I recommend MAIN be on the opposite side of the enclosure from your 915MHz antenna for meshtastic. GNSS is passive so won't interfere, I put that besides the main meshtastic antenna. 

GPS works absolutely fine off the included LTE antenna. I'm connecting to 10-12 GPS sats indoors. If you need hyper accurate time, get an active GPS antenna.


### Setup 

This is brand new and I'm still working through the config. Please reach out if you run into any issues.

```shell

# install nmcli tools and everything else that'll be needed
sudo apt update
sudo apt install network-manager modemmanager gpsd gpsd-clients chrony socat

sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

sudo systemctl enable ModemManager
sudo systemctl start ModemManager

# list devices
nmcli device

# list status
mmcli -L
# look for /org/freedesktop/ModemManager1/Modem/0 [QUECTEL INCORPORATED] EG25

# If modem is 0 use -m 0 for everything, if 1 change to -m 1
sudo mmcli -m 0 --enable

# Activate cell modem without data
sudo nmcli connection add type gsm ifname "*" con-name mycell
# If you actually want to use the data, use:
# sudo nmcli connection add type gsm ifname "*" con-name mycell gsm.apn <your_carrier_apn>
sudo nmcli connection up mycell
sudo nmcli connection modify mycell connection.autoconnect yes


# run to ID ports
mmcli -m 0 
# output should be: ports: cdc-wdm0 (qmi), ttyUSB0 (qcdm), ttyUSB1 (gps), ttyUSB2 (at), ttyUSB3 (at), wwan0 (net)
# Note which one is (gps)

# Enable GPS
#
# DO NOT USE ANY OTHER GPS MODES! 
# gps-unmanaged lets you use gpsd, enabling any other gps modes (nmea) makes modemmanager take control of the GPS feed
#
sudo mmcli -m 0 --location-enable-gps-unmanaged
sudo mmcli -m 0 --location-set-enable-signal
sudo mmcli -m 0 --location-get
mmcli -m 0 --location-status


# sudo nano /etc/default/gpsd
#
# change /dev/ttyUSB1 to whatever port above uses (gps)
sudo tee /etc/default/gpsd > /dev/null <<'EOF'
START_DAEMON="true"
GPSD_OPTIONS="-n"
DEVICES="/dev/ttyUSB1"
USBAUTO="false"
# Socket-activated service will start gpsd when a client connects.
EOF

# Turn on gpsd
sudo systemctl enable --now gpsd
sudo systemctl start gpsd


#
# Connecting gpsd to meshtastic
#
# Meshtastic only seems to support SerialPath. I went with PTY rather than FIFO so that it can pass traffic via TTY.

# PTY creator
sudo tee /etc/systemd/system/meshtastic-pty.service > /dev/null <<'EOF'
[Unit]
Description=Meshtastic virtual PTY pair for GPS (socat)
After=network.target

[Service]
Type=simple
RuntimeDirectory=meshtastic
# Create two PTYs with stable links and permissive mode (tighten later if desired)
ExecStart=/usr/bin/env socat -d -d pty,raw,echo=0,link=/run/meshtastic/gps_in,mode=666 pty,raw,echo=0,link=/run/meshtastic/gps_feed,mode=666
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

# GPS pipe feeder
sudo tee /etc/systemd/system/meshtastic-gpspipe.service > /dev/null <<'EOF'
[Unit]
Description=Feed NMEA from gpsd into Meshtastic PTY
Requires=meshtastic-pty.service gpsd.service
After=meshtastic-pty.service gpsd.service

[Service]
Type=simple
# Wait until the PTY appears and is a char device; then stream raw NMEA
ExecStart=/bin/sh -lc 'while [ ! -c /run/meshtastic/gps_feed ]; do sleep 0.5; done; exec /usr/bin/env gpspipe -r > /run/meshtastic/gps_feed'
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

#
# End of services setup
#

# Enable and startup the meshtastic GPS services
sudo systemctl daemon-reload
sudo systemctl enable --now meshtastic-pty.service
sudo systemctl enable --now meshtastic-gpspipe.service
sudo systemctl start --now meshtastic-pty.service
sudo systemctl start --now meshtastic-gpspipe.service
systemctl --no-pager status meshtastic-pty meshtastic-gpspipe

# troubleshooting - you should see gps_feed and gps_in 
ls -l /run/meshtastic

# check for gps data - you should see a stream of NMEA traffic
sudo timeout 3 cat /run/meshtastic/gps_in

# Log check - make sure no errors
journalctl -u meshtastic-pty -b --no-pager

# point meshtasticd at the new serial feed
sudo nano /etc/meshtasticd/config.yaml

# Change /dev/ttyS0 to /run/meshtastic/gps_in , be careful of the spacing. YAML is sensitive about it. 
# Example:
#GPS:
#  SerialPath: /run/meshtastic/gps_in

#
# Meshtastic gps done 
#


# Connect GPS to system timeout
sudo nano /etc/chrony/chrony.conf
# add to end:
## GPS via gpsd
#refclock SHM 0 offset 0.5 delay 0.2 refid GPS poll 4

# Turn on the service 
sudo systemctl enable --now gpsd-time.service
sudo systemctl start --now gpsd-time.service
systemctl status gpsd-time.service --no-pager
sudo systemctl restart chrony
sudo systemctl restart gpsd

# Troubleshooting
#
# Run this and make sure it's filled with tons of updating numbers
cgps -s
# Check and see if you're getting GPS time data
chronyc sources -v
```

### PPS?

Allegedly Quectel EG25-G does partially support PPS, which allows really accurate time keeping. We'd need to connect a wire from one of the pins on the card to one of the GPIO pins. This would bring down time inaccuracy to a few ms. But I haven't poked at it yet. 


### Alternative setup

https://www.waveshare.com/wiki/EG25-G_mPCIe#How_to_Install_and_Use_Dial-up_Tool_.28Required_for_module_usage.29

Waveshare has an install script you can go with. I haven't tried it out yet.


### Making sure the modem GPS is turned on

Make sure flock is installed, you can check with sudo apt install util-linux

Write the following with sudo nano /usr/local/bin/check_mm_location.sh

This is still a work in progress. 

```shell
#!/bin/bash
# Ensure ModemManager location features are on for all detected modems.
# Requires: mmcli, flock. Run as root (cron/systemd).

set -euo pipefail

LOG_FILE="/var/log/mm-location-monitor.log"
MMCLI="${MMCLI:-/usr/bin/mmcli}"
DATE="/bin/date"
FLOCK="/usr/bin/flock"
LOCKFILE="/var/lock/mm-location-monitor.lock"

log() {
  echo "$($DATE '+%Y-%m-%d %H:%M:%S')  $*" | tee -a "$LOG_FILE"
}

list_modem_ids() {
  # Output: one modem ID per line (e.g., 0, 1, 2 ...), or nothing if none exist
  # mmcli -L example line:
  # /org/freedesktop/ModemManager1/Modem/1 [QUALCOMM INCORPORATED] QUECTEL Mobile Broadband Module
  "$MMCLI" -L 2>/dev/null | sed -En 's#.*/Modem/([0-9]+).*#\1#p'
}

check_and_fix_modem() {
  local MID="$1"

  # Verify the modem exists
  if ! "$MMCLI" -m "$MID" >/dev/null 2>&1; then
    log "modem $MID: not present; skipping"
    return 0
  fi

  # Read location status
  local STATUS
  if ! STATUS="$("$MMCLI" -m "$MID" --location-status 2>&1)"; then
    log "modem $MID: failed to read location-status"
    return 1
  fi

  # Quick capability check; if modem doesn't support gps-unmanaged, don't spam errors
  local CAP_LINE
  CAP_LINE="$(echo "$STATUS" | grep -E '^\s*\|\s*capabilities:' || true)"
  if ! echo "$CAP_LINE" | grep -q 'gps-unmanaged'; then
    log "modem $MID: no gps-unmanaged capability; skipping gps enable"
  fi

  # Parse "enabled" and "signals"
  local ENABLED_LINE SIGNALS_LINE
  ENABLED_LINE="$(echo "$STATUS"  | grep -E '^\s*\|\s*enabled:'  || true)"
  SIGNALS_LINE="$(echo "$STATUS"  | grep -E '^\s*\|\s*signals:'  || true)"

  local HAS_GPS_UNMANAGED="no" HAS_SIGNALS="no"
  if echo "$ENABLED_LINE" | grep -q 'gps-unmanaged'; then HAS_GPS_UNMANAGED="yes"; fi
  if echo "$SIGNALS_LINE" | grep -q 'yes'; then HAS_SIGNALS="yes"; fi

  local changed="no"

  # Enable gps-unmanaged if missing and supported
  if [ "$HAS_GPS_UNMANAGED" != "yes" ] && echo "$CAP_LINE" | grep -q 'gps-unmanaged'; then
    if "$MMCLI" -m "$MID" --location-enable-gps-unmanaged >/dev/null 2>&1; then
      log "modem $MID: enabled gps-unmanaged"
      changed="yes"
    else
      log "modem $MID: FAILED to enable gps-unmanaged"
    fi
  fi

  # Enable signals if missing (try both flags for compatibility)
  if [ "$HAS_SIGNALS" != "yes" ]; then
    if "$MMCLI" -m "$MID" --location-enable-signals >/dev/null 2>&1; then
      log "modem $MID: enabled signals"
      changed="yes"
    elif "$MMCLI" -m "$MID" --location-set-enable-signal >/dev/null 2>&1; then
      log "modem $MID: enabled signals (compat flag)"
      changed="yes"
    else
      log "modem $MID: FAILED to enable signals"
    fi
  fi

  # Dump refreshed status if anything changed
  if [ "$changed" = "yes" ]; then
    "$MMCLI" -m "$MID" --location-status | sed 's/^/modem '"$MID"': /' | tee -a "$LOG_FILE" >/dev/null
  else
    log "modem $MID: already OK (gps-unmanaged + signals)"
  fi
}

_main_run() {
  local any=0
  while IFS= read -r MID; do
    any=1
    check_and_fix_modem "$MID"
  done < <(list_modem_ids)

  if [ "$any" -eq 0 ]; then
    log "no modems detected by ModemManager"
  fi
}

main() {
  # Serialize concurrent runs
  exec "$FLOCK" -n "$LOCKFILE" -c "$0" _run 2>/dev/null || exit 0
}

if [ "${1:-}" = "_run" ]; then
  _main_run
else
  main
fi
```

You can set it up with

```shell
sudo chmod 755 /usr/local/bin/check_mm_location.sh
sudo chmod +x /usr/local/bin/check_mm_location.sh
sudo touch /var/log/mm-location-monitor.log
sudo chown root:adm /var/log/mm-location-monitor.log 2>/dev/null || true
sudo crontab -e
# 0 * * * * /usr/local/bin/check_mm_location.sh

```






