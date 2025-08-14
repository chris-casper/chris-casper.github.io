---
title: "Recycling Old Crypto Miners"
excerpt: "Low cost high power Lora Mesh networking"
last_modified_at: 2025-08-12 20:00:00
tags:
  - Meshtastic
  - lora
  - crypto
---



### Recycling Old Crypto Miners for Something Useful

Helium Coin was/is a crypto coin that got run up in value and then crashed. Regardless of one's opinion, a lot of people bought $750 crypto miners that now aren't very useful. Rather than ending up as rather expensive eWaste, they can be repurposed for Meshtastic.

### Hardware Details

The kit comes with:
- 915 Mhz antenna (advertised as 3 dbi)
- 2.4 Mhz antenna
- Very nice aluminium case
- Hardware (pole mount, spare glands, spare plugs)
- Electronics with a Pi 3 CM
- Has USB WiFi and Bluetooth

They can be found on eBay for around $50. If you see one for sale for over a hundred, message the seller and offer them around $50. 

Reach out to WeHooper at [Mountain Mesh](https://mtnme.sh/) in Georgia. They have a number of options. They have Nebra Pi hats that use 40 pin headers (that can also be used on normal Raspberry Pis), [MESHTOAD](https://mtnme.sh/devices/MeshToad/) USB that works for any PC and working on an M2 format card. Hop on their Discord and inquire. 

### Shucking

Honestly, I rip out the USB board. I keep the WiFi and stick that in the single USB port. Bluetooth isn't useful up a tower. 

Make sure all other boards are mounted correctly, no cables are loose, etc. Then stick the Nebra hat on the 40 pin header. 

Yank out the eMMC key. Download and install the [Raspberry Imager](https://www.raspberrypi.com/software/). Try using a USB MicroSD adapter, SD adapter, etc. SanDisk MicroSD adapters don't seem to work. Which models work or don't work is hit and miss, so try until one works. The uGreen USB MicroSD adapter off Amazon worked for me. Use the Raspberry Pi 3 default image and click through. I do recommend setting the system defaults in the Imager. 

Once it's finished, plug back into the miner and fire up SSH.

Here's the commands to get Meshtasticd working:

```shell
# Update the RPi
sudo apt update
sudo apt upgrade

# Add Meshtastic repo
echo 'deb http://download.opensuse.org/repositories/network:/Meshtastic:/beta/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/network:Meshtastic:beta.list
curl -fsSL https://download.opensuse.org/repositories/network:Meshtastic:beta/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/network_Meshtastic_beta.gpg > /dev/null
sudo apt update
sudo apt install meshtasticd

# Enable SPI on the RPi
sudo raspi-config nonint set_config_var dtparam=spi on /boot/firmware/config.txt # Enable SPI

# Ensure dtoverlay=spi0-0cs is set in /boot/firmware/config.txt without altering dtoverlay=vc4-kms-v3d or dtparam=uart0
sudo sed -i -e '/^\s*#\?\s*dtoverlay\s*=\s*vc4-kms-v3d/! s/^\s*#\?\s*(dtoverlay|dtparam\s*=\s*uart0)\s*=.*/dtoverlay=spi0-0cs/' /boot/firmware/config.txt

# Insert dtoverlay=spi0-0cs after dtparam=spi=on if not already present
if ! sudo grep -q '^\s*dtoverlay=spi0-0cs' /boot/firmware/config.txt; then
    sudo sed -i '/^\s*dtparam=spi=on/a dtoverlay=spi0-0cs' /boot/firmware/config.txt
fi

#
# reboot the RPI here
#
sudo reboot

#
# Setup the hat before turning on Meshtastic to avoid damaging the radio
#
# Documentation at https://github.com/wehooper4/Meshtastic-Hardware/tree/main/NebraHat
# 
# Select the model you bought:
# wget –O /etc/meshtasticd/config.d/NebraHat_2W.yaml https://github.com/wehooper4/Meshtastic-Hardware/raw/refs/heads/main/NebraHat/NebraHat_1W.yaml
# wget –O /etc/meshtasticd/config.d/NebraHat_2W.yaml https://github.com/wehooper4/Meshtastic-Hardware/raw/refs/heads/main/NebraHat/NebraHat_2W.yaml

sudo nano /etc/meshtasticd/config.yaml
# Honestly you can leave the web service turned off. API is enough
# Set either the MAC address or MACAddressSource, not both. It's at bottom of YAML. Eth0 is best choice

sudo nano /etc/meshtasticd/config.d/NebraHat_2W.yaml
# Verify power level is set to 8 or lower. Obviously change 2W to 1W if purchased that model. 
# Shouldn't need to make changes, but if you have problems below such as "No sx1262 radio" uncomment the CS line
# to look for errors: journalctl -xeu meshtasticd.service 

sudo systemctl enable meshtasticd
sudo systemctl start meshtasticd
sudo systemctl status meshtasticd

# To troubleshoot, systemctl stop meshtasticd
# Then run "meshtasticd" by itself in CLI to look for errors
```

Once it's up and running, fire up the Meshtastic app to configure it. Use the Network option on the Cloud tab in the app. 

### Prepping Miner for Outdoor Deployment

It's mostly fine as-is. But you can and should take additional steps. 

The alleged 3 dbi antenna isn't terrible. But you can [upgrade](https://store.rokland.com/collections/all-helium-antennnas/products/5-8-dbi-n-male-omni-outdoor-915-mhz-antenna-large-profile-32-height-for-helium-rak-miner-2-nebra-indoor-bobcat) it. 

The silver rope goes into the lid that doesn't have a gasket already in it. You will have to trim it a touch.

If going onto a tower, you'll need ethernet surge protectors on both ends. I use Ubiquiti ETH-SP-G2. For inside the case, I rip out the board and wrap it. You'll want to attach a bimetallic grounding lug to a post inside the case. Or screw the surge protector to a post and ground there. Aluminum and copper smooshed together will cause corrosion. Do not solder any grounding. Attach a line to the post, attach another line to the ethernet surge protector, and run them outside the case to another line to your ground. Use a split bolt to connect the wires, connect to the tower itself or grounding system. You can also use a second lightning arrestor directly onto the N bulkhead. 

On the bottom of the tower, use another surge protector but this time leave the case on and connect to a copper grounding rod. 

I wrap anything threaded with teflon pipe tape. Every gland, bulkhead and plug. 

I wrap the solar panel line connectors with silicon tape, plus the bulkheads. As well as spiral wrap for air hoses, to hopefully keep wildlife from eating the cables.

I use a [mounting bracket](https://www.amazon.com/dp/B0BVT4J3FF) to connect the solar panel to the miner, along with metal hose clamp. The solar panel I had used a 1/4 course threaded nut.
