---
title: "Recycling Old Crypto Miners - Nebra"
excerpt: "Low cost high power Lora Mesh networking"
last_modified_at: 2025-08-12 20:00:00
tags:
  - Meshtastic
  - lora
  - crypto
---


![Meshtastic Pi](/images/posts/nebra/nebra-pi.png)

### Recycling Old Crypto Miners for Something Useful

Helium Coin was/is a crypto coin that got run up in value and then crashed. Regardless of one's opinion, a lot of people bought $750 crypto miners that now aren't very useful. Rather than ending up as rather expensive eWaste, they can be repurposed for Meshtastic.

The model I've been able to find pretty decently is the <a href="https://helium.nebra.com/pdfs/outdoor-overview.pdf">Nebra Outdoor Hotspot Miner</a>. It has pretty good specs across the board. A Pi CM4 would have been nice, but it was likely a combination of price, power and heat. Waveshare does have a CM4 to CM3 adapter that might be worth playing around with if you want processing power up the tower for some niche circumstance.  

I have started ordering additional outdoor miners to see if any others would be trivially converted to Meshtastic. 


### Hardware Details

The kit comes with:
- 915 Mhz antenna (advertised as 3 dbi)
- 2.4 Mhz antenna
- Very nice aluminium case
- Hardware (pole mount, spare glands, spare plugs)
- Electronics - Pi CM3
- Has USB WiFi and Bluetooth

They can be found on eBay for around $50. If you see one for sale for over a hundred, message the seller and offer them around $50. They need 12VDC barrel connector or POE, it draws too much for USB. It's also not great for solar power (12-15W) and not recommended.

There is also a 4G module available if you have cell coverage and want remote access. The "Quectel EG25-G Mini PCIe 4G Mobile Broadband Card w/ Antennas" originally were pricy but can be found on eBay pretty economically. I ordered some and will update once I noodled them out. There are some data only plans for a few dollars a month. 

Reach out to WeHooper at [Mountain Mesh](https://mtnme.sh/) in Georgia. They have a number of options: Nebra Pi hats that use 40 pin headers (that can also be used on normal Raspberry Pis), [MESHTOAD](https://mtnme.sh/devices/MeshToad/) USB that works for any PC and developing an M2 format card (still early prototype). Hop on their Discord and inquire. 

### Shucking

Honestly, I rip out the USB board. I keep the WiFi and stick that in the single USB port. Nebra Bluetooth adapter is VERY short range and doesn't have any connectors for an external antenna. If you want to keep the USB board, you'll need pass-through headers for the Nebra hat.

Make sure all other boards are mounted correctly, no cables are loose, etc. Then stick the Nebra hat on the 40 pin header. 

Yank out the eMMC key, it's the small device with the gold dot on it right next to the green Pi board. Download and install the [Raspberry Imager](https://www.raspberrypi.com/software/). Try using a USB MicroSD adapter, SD adapter, etc. SanDisk MicroSD adapters don't seem to work. Which models work or don't work is hit and miss, so try until one works. The uGreen USB MicroSD adapter off Amazon worked for me. Use the Raspberry Pi 3 default image and click through. I do recommend setting the system defaults in the Imager. 

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

### The Power of the Sun!

If you got your nebra and don't want to muck around with configuring a Pi, there is a simple solution. Rip everything out. 

![Assembled Unit](/images/posts/nebra/assembled.png)

Wisblock is pretty much the choice for solar repeaters, it absolutely sips power. 

You can print a <a href="https://www.printables.com/model/893147-meshtastic-nebra-ip67-mounting-plate">Meshtastic Nebra mounting plate</a>. It seems to work fine in PETG, but I printed my production models in ASA. You can and should remove material from the plate to fit your antenna bulkheads. 

Once you're completely shucked the case, mount a WisBlock to the backboard. #2 screws worked and you don't need to pre-drill. A 7000mAh battery will fit perfectly, but is extreme overkill. Even a single 18650 would be fine and last for days if not a week. The only annoying quirk of the Wisblock is that it draws so little power, most USB battery packs will turn off. 

BE VERY CAREFUL WITH THE BATTERY WIRING, YOU CAN EASILY FRY THE BOARD IF THE WIRING IS REVERSED. 

I used shorter IPEX cabled bulkheads. With only 0.15W of transmitting power, all loss should be kept to a minimum and you want to mount the 900MHz antenna directly onto the bulkhead. And the 2.4 GHz WiFi antenna works fine for Bluetooth on the Wisblock. But if you want to save money, the bulkheads included will work fine. If you haven't used an IPEX connector, it will take slightly more force than you think it would, but you have to be careful not to snap the connector. I typically press it on with the flat of a flathead screwdriver while holding the cable to hold the connector in position. 

I use a <a href="https://www.printables.com/model/1264626-rak-ipex-pigtail-bracket">bracket</a> to hold the connectors in place. But I don't use nylon or any screws on the cover bracket unless it's to be used in high vibration environment. 

![Mount](/images/posts/nebra/mount.png)

I use a [mounting bracket](https://www.amazon.com/dp/B0BVT4J3FF) to connect the solar panel to the miner, along with metal hose clamp. The solar panel I had used a 1/4 course threaded nut. The hose clamps are probably the most secure way to fasten the two together. 

I wrap the solar panel line connectors with silicon tape, plus the bulkheads. As well as spiral wrap for air hoses, to hopefully keep wildlife from eating the external power cable.

![Deployed Unit](/images/posts/nebra/deployed.png)