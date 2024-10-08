---
title: "Infor IQM API - Reading Data from Mongoose"
excerpt: "First article on Infor API"
last_modified_at: 2024-08-25 20:00:00
tags:
  - Infor
  - IQM
  - Programming
  - REST API
---



## OEM documentation

Infor Mongoose REST API - [Link](https://docs.infor.com/mg/2023.x/en-us/mongooseolh/default.html?helpcontent=rwn1573170285401.html)  
Infor Mongoose Youtube Channel - [Link](https://www.youtube.com/playlist?list=PLQe-TQ28qm-ijxPSNmP2qDHicVyS6x46g)  
Infor IQM User Manual - [Link](https://docs.infor.com/iqm/10.x/en-us/useradminlist/default.html)  
  
Infor does not provide a lot of IQM documentation, just the user manual and admin manual. IQM is predominently just a number of Mongoose forms. And there's quite a bit more Infor Mongoose documentation, as you can tell from the above links. Let alone having its own playlist of Infor documentation on Youtube. Not everything will be applicable, you don't get all the best features Mongoose has available if you just have IQM. 
  
The most useful bit of documentation is the basic REST API call. I stick to API v2, v1 still works fine. 
  
The base call will always be http://(serverName)/IDORequestService/ido


## Authentication

The documentation doesn't explain tokens well but it does make sense in retrospect. Pick the URL to specify the environment, change IQM, IQMDEV or IQMPLAY to your environment's name. When you get the token, you'll need to add that to the headers of your future requests. It specifies the account permission but also which environment you're using.
  
It is persistant, so you don't need to make the token request repeatedly. I could have added the code programmatically, but easy enough to grab manually. 
  
http://(serverName)/IDORequestService/ido/token/IQM/sa/PW_HERE
http://(serverName)/IDORequestService/ido/token/IQMDEV/sa/PW_HERE
http://(serverName)/IDORequestService/ido/token/IQMPLAY/sa/PW_HERE


## Demo Code in Powershell

I wrote the API call in powershell because it's on every machine. Infor prefers C# or VB.   
  
You only need to change the $request and $properties lines. Everything else is basically static, no matter what data you're looking for. Generally, I comment out the $properties line to find all the properties when calling an IDO. Then do another call with the properties to make life easier.  
  
You can also switch to piping the output to CSV file. 


```powershell
#
#  GetUsers.ps1
#
#  Written by Chris Casper
#  v1.0 - 2024.08.20
#
#  Infor Ref URL - https://docs.infor.com/mg/2023.x/en-us/mongooseolh/default.html?helpcontent=dou1573771437358.html
#  Uses IQM API v2
#


# IDO Request
$request = "load/usernames"
#$properties = "?properties=userid"

# Static Variables
$Method = “Get”
$Server = "server" # Put server name here
$Base = "http://$server/IDORequestService/ido/"
$Auth = "b/XdI6IQzCviZOGJ0E" # Put token here
$headers = @{Authorization = "$auth"}

$uri = $base + $request
#$uri = $base + $request + $properties


# API call
$response = Invoke-RestMethod -Method $Method -URI $URI -Headers $headers -ContentType "application/json"
# Output to Command Line or CSV
$response.items
# $response.items | Export-Csv c:\temp\iqm_users.csv -NoTypeInformation
```

## Finding IDO names

You can find all of the IQM specific IDO's by making the following SQL query. Plug them into te $request line.  

```sql
use IQM_DB;
select * from dbo.VQ_FORMS
```

As an example, switch from $request = "load/usernames" to $request =  "load/vqskills"


## Curl

You can just do your API calls with curl.  Good for one-off situations.

```
curl --request GET \
  --url http://(server)/IDORequestService/ido/load/vqunits \
  --header 'Authorization: b/XdI6IQzCviZOGJ0E'
```

## IDE Recommendation  

For development, an IDE makes life a lot easier. Since postman has gone downhill, I recommend [Hoppscotch](https://hoppscotch.io/) these days. You'll need the desktop app for local development. 

## Authorization

Setup a collection for your IQM server.  
Right click, go to Properties.  
Go to Authorization tab, select "API Key", and paste in just the token starting with b/. Leave as Pass by Headers.  
Make sure Enabled is checked. 

## Parameters

Open a new tab, select method to GET.  
Paste in URL like http://(server)/IDORequestService/ido/load/usernames  
Under parameters, put "properties" on the left side.  
On the right hand side, put in "Username,UserDesc"
