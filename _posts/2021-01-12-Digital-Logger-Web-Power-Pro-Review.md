---
title: "Digital Logger Web Power Switch Pro Model"
excerpt: "Great hardware, absolutely terrible software"
last_modified_at: 2020-05-23 17:00:00
tags:
  - iot
  - home-automation
  - hardware
  - review
---

I wrote a [review](https://www.amazon.com/Web-Power-Switch-Pro-Model/dp/B0765NCB2L) on Amazon that I fired off and more or less forgot about for a while. I mentioned it in passing on Reddit, and quite a few people mentioned that they had read it. Apparently liking it. So figured I should put it up. It's probably a bit irrational writing a several page comprehensive review because of the return policy of a company. But made me feel better to write it out, and some folks found it helpful.

![](images/posts/webpower.jpg)

>
> The hardware specs are amazing. The build quality is extremely good and durable. Spacing between power outlets is great. Even the mounting options are fantastic. I didn't do a hardware teardown, but the specs for everything made me buy the product in the first place. Whoever did the hardware engineering did it right.
>
> The software is the absolute opposite. It ranges "bare minimum" to "terrible" to "non-functional". The interface is classic 1990's pure HTML that is not user friendly. I wouldn't care if it was functional and easy to find what you need, but it's really not. The layout isn't great. I bought it for autoping, and that doesn't work reliably. I tried setting up MQTT, that didn't work. It has a range of other alleged features, most are badly documented and it's generally not worth trying to setup. Aside from SNMP, that usually works. Allegedly MQTT was fixed, but I moved on. Documentation isn't great, again more 90's look and quality. Bare minimum. Support is responsive enough.
>
> Updates are manual, semi hidden, two part and annoying. If I COULD modify this thing, I could fix that myself in about an hour or two. But be a bit skeptical of the 'open source' part. It's fairly locked down. Oh, and the most recent upgrades have decreased reliability. The web interface has crashed a couple times now (fork issue apparently), then you have to reboot the entire power strip. A external button to reboot the embedded OS and not everything plugged in would have been bloody nice. If you plug in servers, be cautious about updates. Don't if you can.
>
> The hardware screen and buttons are more or less not useful, but look cool. You'll never use it. If you're using the menu, it's 20x faster just to unplug the cable right below.
>
> It's 'open source', but they make it difficult to impossible to easily modify the software running the Web Power Switch Pro. I was fully intending on writing my own shell and web interface from scratch. That's how poor the web interface is. I figured, open source, if it's broken, I can fix it myself! Not so much. I might go back and see if I can snag the firmware, crack it open like an egg and rewrite everything hoping they either don't use a signed bootloader or I can short some pads/jumpers to bypass.
>
> It runs Linux so this would have had an insane amount of potential for tiny tasks that I now offload to a RPi. But nope, you're locked out of all that. If they gave a damn about software, the potential for on-board apps would be great.
>
> I bought this primarily for the Auto-Ping. Check and see if the internet is up. If not, reboot the modem. Simple, no? First, the auto-ping config page is terrible. The documentation on how to use the auto-ping configuration page more or less expects you to know how to use the auto-ping configuration page. The icons are tiny, so don't expect to easily use it via your phone. There is no mobile app, of course. You plug in the IPs (figure out which ones yourself, no suggestions offered) and check the outlets. Then it sometimes works and sometimes doesn't. It would put a redbox around the IPs and stop working. No notice and the logging is basic/terrible.
>
> So now I leave the config as basic as possible and put a RPi next to it to control it with curl commands. My recommendation is to ignore the interface entirely, do absolutely minimal configuration and strictly control it externally. Don't trust the web interface whatsoever.
>
> This was definitely a product made by an engineer. The hardware is awesome, and absolutely zero regard for the end user who has to actually use it. And they made it difficult for other people to fix the problems.
>
> ************************************
>
> 2020.06.02 Edit - Changed from three star to one star.
>
> I gave it one last try and contacted support who naturally recommended a firmware upgrade, 1.8.12.0 / 1.8.12.0. Upon performing the upgrade, the unit became non responsive except for constant beeping. Support authorized a power reset about 15, 20 minutes into the endless, non-stop beeping. The unit then displayed an error message. With the beeping. Which nothing will stop except removal of power. Attempts at troubleshooting per Support's guidance were unsuccessful. If they do accept an RMA of the unit, I firmly intend to sell it and purchase a replacement. Or just eat the loss and move on. This product has probably been the worst purchase I have made in some time. Which is saying something, as I have worked in enterprise IT for two decades.
>
> I still admire the work of the hardware engineer(s) and will say he/she/they is or are excellent. Support tries their best with dodgy software. To the developers at Digital Loggers (frontend, firmware and backend), please find another line of work. What could have been and should have been an excellent product is a failure even when your customer has put in tens of hours of work attempting to make your product work.
>
> EDIT #2 - They offered to RMA the product at my expense. I politely declined as there is no point in wasting more money on a replacement product that will be equally flawed. If it was a bad unit, absolutely would have RMA'd it. That happens and is normal. In this case, the software updates have gotten worse to the point they killed the unit. Had I known and kept it at its original firmware, it would have been a buggy, not great product but an operational one. Now, it's dead as a doornail and I'm not sad to see it go. Eating $160 isn't pleasant, but I already wasted tens of hours on making this thing perform at minimal functionality.
