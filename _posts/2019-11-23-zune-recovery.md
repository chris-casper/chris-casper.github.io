---
title: "Zune Firmware Recovery"
excerpt: "How to reload the firmware on a dead Zune"
last_modified_at: 2019-11-23T09:45:06-05:00
tags: 
  - tech
---



Someone came to me to try to get one working again, now that Microsoft had pulled the plug on the web resources. Why, I have no clue. Of why Microsoft would pull the firmware, but offer it elsewhere. Don't ask me why one would want to use one these days either. But a million of them are probably floating around.

## Zune Files
* [Zune Firmware](http://go.microsoft.com/fwlink/?LinkId=185560)
* [Zune Software](https://www.microsoft.com/en-us/download/details.aspx?id=27163)

## Additional software
* [Zip Software](http://www.7-zip.org/ or https://ninite.com/)
* [Local Web Server](http://fenixwebserver.com/)

## HOWTO

1. Right click on Zune-Firmware-x86.msi , unzip the firmware to its own folder using 7zip
2. Rename all the files. Basically put a dot in front of CAB or XML.
3. Copy FirmwareUpdate.xml and rename second copy to zuneprod.xml
4. Open zuneprod.xml and edit every incidence of "URL=" to make it look like "url=http://resources.zune.net/(insertfilenamehere).cab"
5. Make a folder called "firmware", then another folder within the firmware folder called "v4_5". So that it looks like /firmware/v4_5/
6. Copy zuneprod.xml to /firmware/v4_5/
7. Find Notepad on your PC. Right click on it, open it as administrator. Within notepad, go to C:\Windows\System32\drivers\etc\
8. Open HOSTS file. Go to the bottom of the file. Add "127.0.0.1 resources.zune.net" on its own line.
9. Fire up Fenix Web Server, use the base folder of that you unzipped the Zune firmware into as the directory and keep port 80.
10. Test by firing up a web browser and going to http://resources.zune.net , you should see the list of files.
11. Install the Zune software
12. After it's running, plug in your Zune. Give it a minute or two. Remember to hold down the power button for 15 seconds if it's turned off.
13. It should complete the firmware upload.