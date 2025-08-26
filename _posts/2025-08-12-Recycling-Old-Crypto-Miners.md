---
title: "Recycling Old Crypto Miners - Nebra"
excerpt: "Low cost high power LoRA Mesh networking"
last_modified_at: 2025-08-23 20:00:00
tags:
  - meshtastic
  - LoRA
  - crypto
---


![meshtastic Pi](/images/posts/nebra/nebra-pi.png)

### Recycling Old Crypto Miners for Something Useful

Helium Coin was/is a crypto coin that got run up in value and then crashed. Regardless of one's opinion, a lot of people bought $750 crypto miners that now aren't very useful. Rather than ending up as rather expensive eWaste, they can be repurposed for meshtastic.

The model I've been able to find pretty decently is the <a href="https://helium.Nebra.com/pdfs/outdoor-overview.pdf">Nebra Outdoor Hotspot Miner</a>. It has pretty good specs across the board. A Pi CM4 would have been nice, but it was likely a combination of price, power and heat. Waveshare does have a CM4 to CM3 adapter that might be worth playing around with if you want processing power up the tower for some niche circumstance.  

I have started ordering additional outdoor miners to see if any others would be trivially converted to meshtastic. 


### Hardware Details

The kit comes with:
- 915 Mhz antenna (advertised as 3 dBi)
- 2.4 Mhz antenna
- Very nice aluminum case
- Hardware (pole mount, spare glands, spare plugs)
- Electronics - Pi CM3
- Has USB WiFi and Bluetooth

They can be found on eBay for around $50. If listed for over $100, try offering around $50. They require a 12 VDC barrel connector or PoE, as they draw too much power for USB. At 12–15 W, they are not ideal for solar operation.

Reach out to WeHooper at [Mountain Mesh](https://mtnme.sh/) in Georgia. They have a number of options: Nebra Pi hats that use 40 pin headers (that can also be used on normal Raspberry Pis), [MESHTOAD](https://mtnme.sh/devices/MeshToad/) USB that works for any PC and developing an M2 format card (still early prototype). Hop on their [Discord](https://discord.gg/4WN32RHGSs) and inquire. 

### Shucking

Honestly, I rip out the USB board. I keep the WiFi and stick that in the single USB port. Nebra Bluetooth adapter is VERY short range and doesn't have any connectors for an external antenna. If you want to keep the USB board, you'll need pass-through headers for the Nebra hat.

If you add new bulkheads, measure them carefully to make sure the main board fits afterwards.

Make sure all other boards are mounted correctly, no cables are loose, etc. Then stick the Nebra hat on the 40 pin header. 

Yank out the eMMC key, it's the small device with the gold dot on it right next to the green Pi board. Download and install the [Raspberry Imager](https://www.raspberrypi.com/software/). Try using a USB MicroSD adapter, SD adapter, etc. SanDisk MicroSD adapters don't seem to work. Compatibility is hit-or-miss, so try different adapters until one works. The uGreen USB MicroSD adapter off Amazon worked for me. Use the Raspberry Pi 3 default image and click through. I do recommend going through the Settings options in the Imager. 

Once it's finished, plug back into the miner and fire up SSH.

Here's the commands to get meshtasticd working:

```shell
# Update the RPi
sudo apt update
sudo apt upgrade
# hit N or Enter when prompted during the long list of installs

# Add meshtastic repo
echo 'deb http://download.opensuse.org/repositories/network:/Meshtastic:/beta/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/network:meshtastic:beta.list
curl -fsSL https://download.opensuse.org/repositories/network:/Meshtastic:/beta/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/network_meshtastic_beta.gpg > /dev/null
sudo apt update
sudo apt install meshtasticd
# Install cli
sudo apt install pipx && pipx install "meshtastic[cli]"
pipx ensurepath


# Enable SPI on the RPi
sudo raspi-config nonint set_config_var dtparam=spi on /boot/firmware/config.txt # Enable SPI

# Ensure dtoverlay=spi0-0cs is set in /boot/firmware/config.txt without altering dtoverlay=vc4-kms-v3d or dtparam=uart0
sudo sed -i -e '/^\s*#\?\s*dtoverlay\s*=\s*vc4-kms-v3d/! s/^\s*#\?\s*(dtoverlay|dtparam\s*=\s*uart0)\s*=.*/dtoverlay=spi0-0cs/' /boot/firmware/config.txt

# Insert dtoverlay=spi0-0cs after dtparam=spi=on if not already present
if ! sudo grep -q '^\s*dtoverlay=spi0-0cs' /boot/firmware/config.txt; then
    sudo sed -i '/^\s*dtparam=spi=on/a dtoverlay=spi0-0cs' /boot/firmware/config.txt
fi

# May also wish to enable I2C now as well: 
# sudo nano /boot/firmware/config.txt
# dtparam=i2c_arm=on

# install I2C tools
sudo apt-get install i2c-tools


#
# reboot the RPI here
#
sudo reboot

#
# Setup the hat before turning on meshtastic to avoid damaging the radio
#
# Documentation at https://github.com/wehooper4/meshtastic-Hardware/tree/main/NebraHat
# 
# Select the model you bought:
# sudo wget –O /etc/meshtasticd/config.d/NebraHat_1W.yaml https://github.com/wehooper4/meshtastic-Hardware/raw/refs/heads/main/NebraHat/NebraHat_1W.yaml
sudo wget –O /etc/meshtasticd/config.d/NebraHat_2W.yaml https://github.com/wehooper4/meshtastic-Hardware/raw/refs/heads/main/NebraHat/NebraHat_2W.yaml


sudo nano /etc/meshtasticd/config.yaml
# Honestly you can leave the web service turned off. API is enough
# Set either the MAC address or MACAddressSource, not both. It's at bottom of YAML. Eth0 is best choice
# I also set maxnodes to 400. 

# Select same model as above
#sudo nano /etc/meshtasticd/config.d/NebraHat_1W.yaml
sudo nano /etc/meshtasticd/config.d/NebraHat_2W.yaml
# If 2W, verify power level is set to 8 or lower. Obviously change 2W to 1W if purchased that model. 
# Shouldn't need to make changes, but if you have problems below such as "No sx1262 radio" uncomment the CS line
# to look for errors: journalctl -xeu meshtasticd.service 

sudo systemctl enable meshtasticd
sudo systemctl start meshtasticd
sudo systemctl status meshtasticd

# To troubleshoot, systemctl stop meshtasticd
# Then run "meshtasticd" by itself in CLI to look for errors
```

Once it's up and running, fire up the meshtastic app to configure it. Use the Network option on the Cloud tab in the app. 

### Sensors

If you have i2c sensors on your board, uncomment "i2cDevice: /dev/i2c-1" in /etc/meshtasticd/config.yaml

And double check /boot/firmware/config.txt to make sure you have i2c enabled. Reboot after making the config.txt and config.yaml changes.

To find out if you have any, run the following.

```shell
sudo apt-get install i2c-tools
i2cdetect -y 1
```

### Grounding

![Nebra Grounding](/images/posts/nebra/nebra_case_grounding.jpg)

Not as important for self-contained solar nodes. But pretty critical if placed on a tower, especially with RF equipment. 

Rip out the USB board, Pi CM3 board and main board. I shucked a $12 Ubiquiti ETH-SP-G2 Surge Protector. They have more capable models and I recommend them if you want to pay the premium. The ETH-SP-G2 is not meant to stop a lightning strike. It's meant to ensure Ethernet pins potential vs the local enclosure ground never exceeds 90-100v and preventing surges/transient power. 

Shucking was just prying it out with a multi-tool, you will bend the metal case a bit but that's fine. The posts in the case seem to be M3. I used normal 12AWG solid core grounding wire crimped (not soldered) to a ring terminator. Check with your tower owner if heavier gauge wire is needed. I do recommend using Noalox on aluminum wiring points, helps prevent oxidation. The ETH-SP-G2 does want to stick up a bit. You want to screw everything together, then use a cheap flathead screwdriver as a chisel and give it some light wraps with a mallet until it's closer to the floor of the case. I put some silicone tape on top, to prevent ground shorts from the system board. 

There will also be a lightning arrestor on the main antenna. The two grounding cables will go to a split bolt and then on to tower ground using ground clamp. Notion is to provide a low-impedance path to ground. 

### Onboard GPS

![NEO-6M](/images/posts/nebra/nebra-gps-neo6m.jpg)

Some of the older Nebra miners have a NEO-6M GPS chip on board. If you don't have a chip, you can add the components to get functionality. But realistically, the [Nebra cell modem](https://casper.im/Nebra-Cell-Modem/) or a UBS GPS would probably be easier. 

```shell

sudo apt install gpsd gpsd-clients chrony socat
sudo nano /boot/firmware/config.txt
# add the following to the end:  
# enable_uart=1
# dtoverlay=uart1,txd1_pin=32,rxd1_pin=33,pin_func=7

sudo raspi-config
# interfaces -> serial ports -> no and then yes.

# sudo nano /etc/default/gpsd
# DEVICES="/dev/serial1"


```


### Cell Modem

![meshtastic cell modem](/images/posts/nebra/nebra-case.jpg)

Please check out a dedicated setup and config post about the [Quectel EG25-G Mini PCIe](https://casper.im/Nebra-Cell-Modem/)

There is also a 4G module available if you have cell coverage and want remote access. The "Quectel EG25-G Mini PCIe 4G Mobile Broadband Card w/ Antennas" originally were pricy but can be found on eBay pretty economically. Card can do 150Mbps down and 50Mbps up, but only if you are using MAIN and DIV connectors. I was very interested in the GPS chip on the EG25-G Mini as it covers GPS, GLONASS, BeiDou/Compass, Galileo and QZSS.

It is possible to use AT commands directly to access the multi-band GPS on the card, but it's frustrating process to put it mildly. Use nmcli. Put your meshtastic and LTE antennas on opposite ends of the case and only use LTE if you have a band pass filter on your LoRa radio. LTE interferes with 915MHz. I would only use the MAIN LTE connector, not the DIV. Higher bandwidth isn't worth displacing the WiFi antenna aimed down. 

The EG25-G and nmcli does need a physical SIM card to work. Otherwise the EG25-G declare itself to be in failed state and complain when you try to get GPS coordinates from it. eSIM is possible but would require a lot of custom coding. 

You can use a normal LTE antenna as a GPS antenna. Indoors I was easily able to get 12 satellites within a few minutes. 





### WiFi AP 

See [https://github.com/wehooper4/meshtastic-Hardware/tree/main/NebraHat/nebraAP](https://github.com/wehooper4/meshtastic-Hardware/tree/main/NebraHat/nebraAP)

For the stock USB WiFi adapter, replace the stock driver to be able to use the Nebra as an AP. This would allow you to connect via laptop. Alternatively you can connect the device to the local WiFi if it will reach. 

I had issues with this and just reverted to stock driver. 

```shell
# Get  RT18188 driver for Debian
wget -O ~/rtl8188eus_1.0-1_arm64.deb https://github.com/wehooper4/meshtastic-Hardware/raw/refs/heads/main/NebraHat/nebraAP/rtl8188eus_1.0-1_arm64.deb
sudo dpkg -i ~/rtl8188eus_1.0-1_arm64.deb

# Remove old driver
echo "blacklist rtl8xxxu" | sudo tee /etc/modprobe.d/rtl8xxxu.conf
sudo dpkg -i rtl8188eus_1.0-1_arm64.deb
sudo modprobe 8188eu

# Reboot
sudo reboot

# After reboot, check what driver is in use
basename $(readlink /sys/class/net/wlan0/device/driver)
# should display 8188eu

```



### Antenna Selection

The stock Nebra antenna as well as similar RAK antennas claim to be 3dBi and tend to be better than random stuff found on Amazon. You can find the common antennas here:

[https://github.com/meshtastic/antenna-reports](https://github.com/meshtastic/antenna-reports)

Remember, SWR isn't going to tell you everything. If you hooked up a 50 Ω resistor to your NanoVNA, it would look perfectly matched — Thanos will tell you it’s perfectly balanced, just as all things should be — but of course it won’t radiate. 

SWR tells you how well your antenna matches your transmitter. Not how well your antenna performs. To do that, you need to hook up the antenna and take measurements at different azimuth and distance. 2:1 SWR means ~11% reflected. The main effect of high SWR for meshtastic is wasted battery and poor range

Commercial antennas tend to be a lot more expensive than consumer ones, but you do get what you pay for. For meshtastic, you ideally want 902-928MHz ISM tuned. Wider tuning (824–960 MHz) will still work decently and better than most consumer antenna. Just not with same efficiency.  

Gain is not magic. It's not adding power, it's shaping it. 0dBi would be a very fat (theoretical and idealized isotropic radiator) donut, handy if you want good coverage in all directions equally. 9dBi would be a very wide pancake, handy if you put on a tower and want to reach other towers. 3-6dBi is compromising between the two. 

Higher gain flattens the vertical beam, turning the donut into a wider, thinner pancake. There is no ideal, only ideal for your purpose. 

Suppose you're putting a meshtastic node on a mountain top tower:

If you want all-purpose coverage from a single mountaintop node, 5 dBi, ISM-tuned is the sweet spot. It won't be great at distance, but it won't leave nearby hikers without coverage either. Incidentally these tend to be expensive antennas. 

If you want maximum long-haul distance, point-to-multipoint across valleys, 6 dBi.

If you want to prioritize hikers and nearby stations at different elevations, 3 dBi would be a good choice.

If you have multiple units, mixing antennas would provide different coverage for different folks. 


Now let's make things even more complicated. It's not JUST the dBi. That shapes the power, but how do we get the power in the first place?

With commercial high quality fiberglass omnidirectional antennas, you're paying the extra for lower conduction/dielectric loss (ohmic heating in conductors, dielectric materials, radome, etc.). High-quality commercial fiberglass omnis often have radiation efficiency >90–95% (loss <0.5 dB). Cheap eBay/Amazon antennas can be much worse — sometimes only 30–60% efficiency. Meaning if you're beaming a watt, you might only be shooting out 300-600 milliwatts for that antenna to shape. 

SWR tells you what fraction of power even makes it into the antenna.
Efficiency tells you how much of that delivered power is actually radiated vs lost as heat.
Together, they give you real radiated efficiency.

Let's suppose you have a great antenna with SWR of 1.5, you'll get a reflection ~4% of TX power and 92.5% antenna efficiency, ~88% of the original watt is radiated. Meaning you get around 0.88W transmitted.

Increase the SWR to 2, you'll get a reflection ~11% of TX power and 92.5% antenna efficiency, ~82% of the original watt is radiated. Meaning you get around 0.82W transmitted.

Suppose you want to add coax instead of mounting your antenna to the ipex bulkhead. 1dB of feedline loss can cost you 20.6% of the watt before it even gets to your expensive commercial antenna. Taking that awesome 0.88W down to 0.71W. 

### Adding fault tolerance

At the moment, if your meshtasticd crashes, nothing will restart it unless you do so manually.

Here's some maintenance code. Hourly status check on meshtasticd service, and weekly reboot just in case.
Do a manual reboot to verify all your startup services.

If you have the node plugged into a network, wouldn't be a terrible idea to run updates on an automated basis. That has trade-offs between things breaking and things being secure. 

```shell

# Detect if meshtasticd is running
sudo tee /usr/local/bin/check_meshtasticd.sh > /dev/null <<'EOF'
#!/bin/bash

SERVICE="meshtasticd"

if ! pgrep -x "$SERVICE" > /dev/null; then
    echo "$(date): $SERVICE not running, restarting..." >> /var/log/meshtasticd_monitor.log
    systemctl restart $SERVICE
fi
EOF

# Make it executable
sudo chmod +x /usr/local/bin/check_meshtasticd.sh

# add to chron
sudo chrontab -e

#Add the following entries:
#
# Hourly check to verify meshtasticd is running and restart if it's not
#0 * * * * /usr/local/bin/check_meshtasticd.sh
# Weekly reboot of node - Monday 1AM
#0 1 * * 1 /sbin/reboot

# Check status log
tail -n 20 /var/log/meshtasticd_monitor.log
```


### Prepping Miner for Outdoor Deployment

It's mostly fine as-is. But you can and should take additional steps. 

The alleged 3 dBi antenna isn't terrible. But you can [upgrade](https://store.rokland.com/collections/all-helium-antennnas/products/5-8-dBi-n-male-omni-outdoor-915-mhz-antenna-large-profile-32-height-for-helium-rak-miner-2-Nebra-indoor-bobcat) it. 

The silver rope is an EMI gasket and goes into the lid that doesn't have a gasket already in it. You will have to trim it a touch, the ends unravel quickly. 

If going onto a tower, you'll need ethernet surge protectors on both ends. I use Ubiquiti ETH-SP-G2. For inside the case, I rip out the board and wrap it. You'll want to attach a bimetallic grounding lug to a post inside the case. Or screw the surge protector to a post and ground there. Aluminum and copper smooshed together will cause corrosion. Do not solder any grounding. Attach a line to the post, attach another line to the ethernet surge protector, and run them outside the case to another line to your ground. Use a split bolt to connect the wires, connect to the tower itself or grounding system. You can also use a second lightning arrestor directly onto the N bulkhead. 

On the bottom of the tower, use another surge protector but this time leave the case on and connect to a copper grounding rod. 

I wrap anything threaded with teflon pipe tape. Every gland, bulkhead and plug. 

### The Power of the Sun!

If you got your Nebra and don't want to muck around with configuring a Pi, there is a simple solution. Rip everything out. 

![Assembled Unit](/images/posts/nebra/assembled.png)

Wisblock is pretty much the choice for solar repeaters, it absolutely sips power. 

You can print a <a href="https://www.printables.com/model/893147-meshtastic-Nebra-ip67-mounting-plate">meshtastic Nebra mounting plate</a>. It seems to work fine in PETG, but I printed my production models in ASA. You can and should remove material from the plate to fit your antenna bulkheads. 

Once you're completely shucked the case, mount a WisBlock to the backboard. #2 screws worked and you don't need to pre-drill. A 7000mAh battery will fit perfectly, but is extreme overkill. Even a single 18650 would be fine and last for days if not a week. The only annoying quirk of the Wisblock is that it draws so little power, most USB battery packs will turn off. 

BE VERY CAREFUL WITH THE BATTERY WIRING, YOU CAN EASILY FRY THE BOARD IF THE WIRING IS REVERSED. Verify the + marking on the battery, and the + next to the battery connector. Do not rely on wire color. 

I used shorter IPEX cabled bulkheads. With only 0.15W of transmitting power, all loss should be kept to a minimum and you want to mount the 900MHz antenna directly onto the bulkhead. And the 2.4 GHz WiFi antenna works fine for Bluetooth on the Wisblock. But if you want to save money, the bulkheads included will work fine. If you haven't used an IPEX connector, it will take slightly more force than you think it would, but you have to be careful not to snap the connector. I typically press it on with the flat of a flathead screwdriver while holding the cable to hold the connector in position. 

I use a <a href="https://www.printables.com/model/1264626-rak-ipex-pigtail-bracket">bracket</a> to hold the connectors in place. But I don't use nylon or any screws on the cover bracket unless it's to be used in high vibration environment. 

![Mount](/images/posts/nebra/mount.png)

I use a [mounting bracket](https://www.amazon.com/dp/B0BVT4J3FF) to connect the solar panel to the miner, along with metal hose clamp. The solar panel I had used a 1/4 course threaded nut. The hose clamps are probably the most secure way to fasten the two together. 

I wrap the solar panel line connectors with silicon tape, plus the bulkheads. As well as spiral wrap for air hoses, to hopefully keep wildlife from eating the external power cable.

![Deployed Unit](/images/posts/nebra/deployed.png)