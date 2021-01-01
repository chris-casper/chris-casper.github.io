---
title: "Cylance Script Control and SCCM"
excerpt: "It does not end well."
last_modified_at: 2020-03-23 17:00:00
tags:
  - SCCM
  - Cylance
---
<br />
Unshockingly, Cylance Script Control blocks powershell by default. This shouldn't be too shocking. It however gets really annoying when you also run SCCM. SCCM is essentially just an asset database, WSUS front end, app deployer and probably most importantly repository of powershell scripts. Everything except Powershell is pull based and it doesn't pull in a quick manner. So, when you want to make an immediate impact on your clients, you have to go with Powershell. And Cylance blocks it. 

Dipping my toes in the water, I tried to see if I could just whitelist the folders that Cylance uses. Nope. SCCM uses randomized file names for pushed Powershell scripts. Not that it matters, even if you whitelist the location, name and SHA-256 hash of the script, it is still blocked. On the other hand, "Powershell -File" is not blocked by Cylance Script Control. SCCM cannot be modified to run scripts using -File. You can write batch file running scripts manually using File and deploy it like any other Package, but it's Pull rather than Push. Which defeats the entire premise. 

I called Cylance and they explained that this is expected. By default, SCCM runs all scripts as "Powershell -Command". Which Cylance blocks. Microsoft wrote Powershell in a way that prevents AntiVirus companies from being able to check commands before evaluating if they're potentially malicious. Cylance is aware of the issue. And is waiting on Microsoft on to fix Powershell. Which will take years, if ever. Cylance doesn't intend on having a whitelist option for SCCM. Their only recommended guidance is turning off script control if you use SCCM. 

It's decently documented in their [Feature Focus](https://www.cylance.com/content/dam/cylance/pdfs/feature-focus/Feature_Focus_CylancePROTECT_Script_Control.pdf)

If you have dozens of clients, it's annoying. If you have hundreds or thousands, it's not realistic to flip script control off and on.

Thankfully you can control it using Powershell and [CyCLI](https://github.com/jan-tee/cycli). Because irony. Launch it from PowerShell ISE. 

Run the following code to install the module.

~~~~PowerShell
Install-Module CyCLI
Import-Module CyCLI
~~~~

Get a list of policies.

~~~~PowerShell
$policy = Get-CyPolicyList
~~~~

You can use a CSV file to control the policy assignment

~~~~PowerShell
$policy = "XXXX" # Set a copy of your main policy but without script control. Get ID with Get-CyPolicyList 
Import-Csv .\PCs.csv | ForEach-Object {
    Set-CyPolicyForDevice -Device $device -Policy $policy
}
~~~~

Voila. Easily switch clients in and out of script control for maintenance windows.

There is also [TietzeIO.CyShell](https://github.com/jan-tee/TietzeIO.CyShell) by the same author. Much faster but a bit more cumbersome to use.


