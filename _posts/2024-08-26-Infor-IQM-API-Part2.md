---
title: "Infor IQM API - Writing Data to Mongoose"
excerpt: "Second article on Infor API"
last_modified_at: 2024-08-25 20:00:00
tags:
  - Infor
  - IQM
  - Programming
  - REST API
---



## Prereq

See last post on tokens, setup, finding IDO names, etc.


## Demo Code in Powershell

I wrote the API call in powershell because it's on every machine. Infor prefers C# or VB.   
  
Unlike the read-only request, Infor doesn't make it extremely easy to add new data. So far the only way I've noodled out is to do a BODY request, which is a big blob of JSON. In production, I'll likely write an encoder to convert CSV files to JSON temp file, and then have this script just get the JSON from the temp file. 

Action is very critical, you'll want to double and triple check

| Code | Action | Result |
| -------- | ------- |------- |
| 1 | Insert | Add new entries |
| 2 | Update | Change/modify existing entries |
| 4 | Delete | Remove existing entries |

You'll want to very carefully look over the JSON from doing a GET request from the same IDO. It's also worth reading over the Infor page on UpdateCollection. 

```powershell
#
#  AddUnits.ps1
#
#  Written by Chris Casper
#  v1.0 - 2024.08.26
#
#  Infor Ref URL - https://docs.infor.com/mg/2022.x/en-us/mongooseolh/default.html?helpcontent=mgiiea/rrd1576802617893.html
#  Uses IQM API v2
#


# IDO Request
$request = "update/vqunits?refresh=true"

# Body
$body = @"
{
  "Changes": [
   {
      "Action": 1,
      "ItemId": "PBT=[vqunits]",
      "Properties": [
         {
            "Name": "Units",
            "Value": "Test04",
            "Modified": true,
            "IsNull": false
         },
         {
            "Name": "Description",
            "Value": null,
            "Modified": true,
            "IsNull": true
         }
      ],
      "UpdateLocking": 1
   }
  ]
}
"@


# Static Variables
$Method = "POST"
$Server = "server_name" # Put server name here
$Base = "http://$server/IDORequestService/ido/"
$Auth = "b/XdI6IQzCviZOGJ0" # Put token here
$headers = @{Authorization = "$auth"}

$uri = $base + $request

# Timestamp for logging
function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

# API call
$response = Invoke-RestMethod -Method $Method -URI $URI -Headers $headers -ContentType "application/json" -Body $body 

# Output to Command Line or log file
Write-Output $(Get-TimeStamp) $response
Write-Output $(Get-TimeStamp) $response >> C:\temp\AddUnitLog.txt
```



