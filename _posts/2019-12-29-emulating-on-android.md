---
title: "Finding a Decent Emulator Handheld Gaming System"
excerpt: "A search for a better Christmas gift goes way, way too far"
last_modified_at: 2019-12-29 01:44:31
tags:
  - DIY
toc: true
---
<br />
# Origin Story

Not that long ago, I was faced with the task of buying a gift for someone. I was working on an IOT project and had been using some single computer boards from ODroid in Korea. They made SBCs similar to a Raspberry Pi, but better specs and native Android support. Which comes in handy if you're using the SBC for kiosks. ODroid was selling a do-it-yourself version of a GameBoy in a kit, called the [ODroid Go](https://ameridroid.com/products/odroid-go-game-kit).

For $35, it looked like a nifty gift. The kid loved it, but her mom did not enjoy the lack of a headphone jack. Really, really, really did not enjoy that lack of headphone options. It also only supported a handful of game system emulator formats, and there's a limited supply of legal ROMs for those. ROMs are the copy of the original game. The term comes from the fact that games used to be stored on physical Read Only Memory chips in cartridges, arcade games and the like. The overwhelming number are pirated, obviously. And I was trying to not go down that route.

Though piracy is pretty clear cut when you're talking about a just released game, but gets more nuanced when you're talking about abandoned software from four decades ago that may or may not have followed copyright procedures. In many cases of such legacy software, the original companies or programmers may no longer be alive. The Internet Archives is doing a wonderful job of tracking down legacy software, and obtaining release rights. The RetroPi community is a good source for looking for legal ROMs, including new games for legacy game systems.

## Some Legal ROM Resources

* [Retropie UK Forum](https://retropie.org.uk/forum/topic/10918/where-to-legally-acquire-content-to-play-on-retropie)
* [MAME Project ROMS](https://www.mamedev.org/roms/)
* [Zophar Public Domain ROMs](https://www.zophar.net/pdroms.html)
* [ROMHacking.net HomeBrew ROMs](http://www.romhacking.net/homebrew/) - Homebrew games are newly written games for legacy systems
* [Internet Archives](https://archive.org/details/internetarcade) - Some can be downloaded, some are streaming only

You can also copy or rip games you legally and physically own, due to a [DMCA Exemption](https://www.copyright.gov/1201/docs/librarian_statement_01.html).

> 37 CFR 201.40 Exemption to prohibition against circumvention
>
> Compilations consisting of lists of Internet locations blocked by commercially marketed filtering software
>
> Computer programs protected by dongles that prevent access due to malfunction or damage and which are obsolete.
>
> Computer programs and video games distributed in formats that have become obsolete and which require the original media or hardware as a condition of access. A format shall be considered obsolete if the machine or system necessary to render perceptible a work stored in that format is no longer manufactured or is no longer reasonably available in the commercial marketplace.
>
> Literary works distributed in ebook format when all existing ebook editions of the work (including digital text editions made available by authorized entities) contain access controls that prevent the enabling of the ebook's read-aloud function and that prevent the enabling of screen readers to render the text into a specialized format.

# Requirements for a Better Mousetrap

I looked around for a bit and eventually found a handheld system that fit most of my bucket list. The GPD XD+ fit the bill quite nicely.

- [x] Headphone support
- [x] Android based
- [x] Handheld format
- [x] Good battery life
- [x] Bluetooth support
- [x] HDMI-Out or MiraCast
- [x] Good storage options
- [x] Good processor
- [ ] Economic
{: style='list-style-type: none'}

Ok, it was a bit more than I'd like. $220 ish, off Amazon. You can go with an [ODroid Go Advanced](https://www.hardkernel.com/shop/odroid-go-advance/) for $55. Less capability, but far cheaper.

The reviews for the GPD XD+ were pretty similar and very positive. Mediatek MT8176 6-core 2.1GHz 64bit processor, PowerVR GX6250 GPU, 4GB RAM and 32GB of onboard storage. Thankfully it has a MicroSD slot, which will support the 400GB MicroSD card I tested out. It has a standard USB port for a thumb drive. A low-profile thumb drive might be a good option. Battery life is around 8 to 10 hours. By default, it comes with Android 7 and the Google Play Store. Charging is Micro-USB. It has a Mini-HDMI and normal audio ports.

# Customizing the Firmware

This is an optional step. Stock firmware is probably OK for most users. CleanROM is just cleaner, fixes some annoyances and more customizable.
{: .notice--info}

Reasons for using CleanROM
* Can use CTS-locked apps like Netflix in the Play store
* Can close lid on unit and still send HDMI out to a TV
* Disables the shoulder buttons when the lid is closed
* Screen and microphone levels are better
* Debloated, more lean
* vsync is fixed, less stutter in emulators


All of the instructions in detail can be found [here](https://gpdcentral.com/tutorials/installing-cleanrom-v2-using-spflash).

It will take an hour or two. If you muck up or run into problems, [XDRescue](http://xdrescue.com/) can help out. You can use a spare MicroSD card to make a rescue disk.

Overview:

1. Snag the latest version of [CleanROM](https://www.gpdcentral.com/downloads/cleanrom-gpd-xd-plus-firmware-rom)
2. Snag the latest version of [Magisk](https://github.com/topjohnwu/Magisk/releases)
3. Cleanly format your MicroSD card, I recommend using [SD Memory Card Formatter](https://www.sdcard.org/downloads/formatter/index.html).
3. Burn CleanROM to a clean MicroSD card using Magisk.
4. Follow the very specific and exact steps listed [here](https://gpdcentral.com/tutorials/installing-cleanrom-v2-using-spflash#ins-rec).

# Emulators

Most of this information was mined off [https://www.reddit.com/r/gpdxd/](https://www.reddit.com/r/gpdxd/), which is a resource I'd highly recommend.

Retroarch is a very powerful frontend for a host of emulator cores, but is not as user friendly. It has a wealth of options that can be quite intimidating. If you're willing to do some research and legwork, that will be the only emulator you will need. It is available from the Play Store. The Dig Frontend is a separate app that might be easier to navigate. Nintendo DS, just go with Drastic rather than Retroarch.

Core recommendations:
- Atari - 2600 (Stella)
- Atari - Lynx (Handy)
- Nintendo - Game Boy / Color (Gambatte)
- Nintendo - Game Boy Advance (mGBA)
- Nintendo - NES / Famicom (Nestopia UE)
- Nintendo - Nintendo 64 (Mupen64 Plus)
- Nintendo - SNES / Famicom (Snes9x 2010)
- Sega - MS/GG/MD/CD (Genesis Plus GX) For megadrive/gg/scd
- Sega - MS/MD/CD/32X (PicoDrive) For 32x (Although you can just pick either of these last two, if you're only interested in Sega Megadrive)
- SNK - Neo Geo Pocket / Color (Beetle NeoPop)

If you want other options, here's the general recommended best emulators for various systems:
- SNES - SNES9x EX+
- Genesis - MD.emu ($)
- GBA - MyBoy, DraStic ($), GBA.emu or PizzaBoy
- GBC - GBC.emu ($), MyOldBoy($),
- NDS - DrasticDS ($)
- PS1 - ePSXe ($) or FPSe($)
- PSP - PPSSPP
- N64 - Mupen64 Plus FZ (make sure to set the emulation profile to GLIDEN64 Medium or Accurate)
- Dreamcast - ReDream
- GameCube - Dolphin
- MAME - mame4droid 0.139u1
- MSDOS - FreeDosBox


# Bluetooth

CleanROM v2.1.0.0 and above support external PS4 controllers. DualShock4 gamepad has had some issues, for some people it works fine. Pretty much any Bluetooth controllers or keyboard will work out of the box. Just be sure to check for Android compatibility.

I picked up a SteelSeries Stratus Duo Wireless Gaming Controller for the gift package.

# Connecting to TV

Any Micro-HDMI to HDMI cables should work, but definitely buy one that supports HDMI 2.0 specifications.

If your TV supports MiraCast, the GPD XD+ can natively support it. This is "Mirror to Screen".

# Stating the obviously

Remember. It's an Android device. You can use it for any Android related task. You can watch Netflix on it, read ebooks, play music, or whatever. With the insane battery life and good storage, it can easily cover a US to Australia flight on one device.

# Results

The kid liked the gift. Which was good for the amount of work that went into it.
