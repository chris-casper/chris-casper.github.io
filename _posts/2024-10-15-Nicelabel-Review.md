---
title: "Infor Visual - NiceLabel LMS Review"
excerpt: "Overview of Visual ERP label printing options"
last_modified_at: 2024-10-14 20:00:00
tags:
  - Infor
  - Infor Visual
  - NiceLabel
---

## Official Support

If you want Infor support, your choice will have to be Nicelabel. Loftware (the company) has depreciated Loftware (the software), which used to be the officially supported label software for Visual ERP. Loftware looked and acted like 1990's software. 

To the best of my knowledge, they purchased Nicelabel (the company and the software), put their logo on it and now do support for it. 

Loftware Nicelabel is the official partner, but both Nicelabel and Infor don't know much about each other. Don't expect a ton of support, but you shouldn't need much.

Both Infor and Nicelabel support will provide the config file for Nicelabel Automation to use to process PAS files however.


## Alternative

Infor allegedly has partial support for Bartender. 5 years ago, I absolutely loved working with Bartender but unfortunately it's now a trainwreck. 

As an example, to have a print station (say in shipping or receiving), you have to install most of the stack of Bartender applications. And those applications are not in a good development state, because they're in the middle of making it more cloud oriented. Might be worth looking at again in a couple years. I evaluated them last year. And they're not offering licenses or support for their older and far more functional versions. If you go that route, skip printing labels from Visual and just grab the info directly from SQL.

## Support

Nicelabel's front line support is flat out terrible. They don't read the ticket, they just copy/paste generic replies very akin to "have you turned it off and back on again?"

But if you escalate tickets, their second and third tier support are excellent. They know their stuff and are super helpful. 

Nicelabel does have a converter to convert Loftware labels to Nicelabel, it does not work remotely well at all. Rewriting from scratch, side by side, will go a lot faster. Have two screens. Put Loftware on one, put Nicelabel on the other. And just manually re-create the elements in the labels. 

Nicelabel's logging is actually excellent. The only issue we ever had was illegal characters in a customer part ID for a barcode-39 field, and I got to it in about 20 seconds by looking for the error in bright red. 

## Thoughts on the software

It works pretty well. It has clunky aspects that are annoying. In Designer, you cannot for example paste in SQL directly when setting up a data link to a label. You have to go through the entire wizard, THEN edit the SQL. Not a show stopper, just clunky. Control panel is excellent. 

The Automation handles folder drops without any issues, that’s how Visual talks to it (PAS files in a drop location). It can do Python scripting, which is a nice bonus that I haven’t poked at yet. It can do API, but we’ve stuck to folder drops. We're using some Nicelabel Solutions (eg forms made inside of their software) and they work decently but there's some basic tasks that are overly complicated. 

Nicelabel's web site is terrible and definitely written by marketing people who want to keep the customer away from useful information. 

Nicelabel's KBs are decent, but largely written around assuming you already know how to use the software.

Nicelabel has pretty limited educational/training material. Aside from an actually pretty good samples directory built into Nicelabel Designer. I assume it's to drive more folks to their Loftware Academy to pay them to teach you how to use designer. Their YouTube channel is filled with marketing videos for marketing people, not for customers or technical people trying to figure out the system. You can find Nicelabel videos from before Loftware's aqusiition of Nicelabel with useful information. 

I know you can use python to do a lot with Nicelabel, but there's not much good material on it. 

Noodling out their printing station software is annoying. Likely because they want to transition to being a Label-as-a-Service cloud provider, which isn't going to happen for the majority of their clients. 

Bartender of 5 years ago was a far superior product. But today, Nicelabel is probably a better product. It does its job well and once you dial it in, you don't have to touch it. 

