---
title: "Useful Powershell Snippets"
excerpt: "Handful of powershell commands that come in handy time to time"
last_modified_at: 2019-11-21T09:45:06-05:00
tags: 
  - snippet
toc: true
---

<script>
    document.querySelectorAll('pre > code').forEach(function (codeBlock) {
    var button = document.createElement('button');
    button.className = 'copy-code-button';
    button.type = 'button';
    button.innerText = 'Copy';

    var pre = codeBlock.parentNode;
    if (pre.parentNode.classList.contains('highlight')) {
        var highlight = pre.parentNode;
        highlight.parentNode.insertBefore(button, highlight);
    } else {
        pre.parentNode.insertBefore(button, pre);
    }
});

function addCopyButtons(clipboard) {
    document.querySelectorAll('pre > code').forEach(function (codeBlock) {
        var button = document.createElement('button');
        button.className = 'copy-code-button';
        button.type = 'button';
        button.innerText = 'Copy';

        button.addEventListener('click', function () {
            clipboard.writeText(codeBlock.innerText).then(function () {
                /* Chrome doesn't seem to blur automatically,
                   leaving the button in a focused state. */
                button.blur();

                button.innerText = 'Copied!';

                setTimeout(function () {
                    button.innerText = 'Copy';
                }, 2000);
            }, function (error) {
                button.innerText = 'Error';
            });
        });

        var pre = codeBlock.parentNode;
        if (pre.parentNode.classList.contains('highlight')) {
            var highlight = pre.parentNode;
            highlight.parentNode.insertBefore(button, highlight);
        } else {
            pre.parentNode.insertBefore(button, pre);
        }
    });
}

if (navigator && navigator.clipboard) {
    addCopyButtons(navigator.clipboard);
} else {
    var script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/clipboard-polyfill/2.7.0/clipboard-polyfill.promise.js';
    script.integrity = 'sha256-waClS2re9NUbXRsryKoof+F9qc1gjjIhc2eT7ZbIv94=';
    script.crossOrigin = 'anonymous';
    script.onload = function() {
        addCopyButtons(clipboard);
    };

    document.body.appendChild(script);
}

</script>
<style>

pre {
    white-space: pre-wrap;
}

.copy-code-button {
    color: #272822;
    background-color: #FFF;
    border-color: #272822;
    border: 2px solid;
    border-radius: 3px 3px 0px 0px;

    /* right-align */
    display: block;
    margin-left: auto;
    margin-right: 0;
    margin-top: 2px;

    margin-bottom: -2px;
    padding: 3px 8px;
    font-size: 0.8em;
}

.copy-code-button:hover {
    cursor: pointer;
    background-color: #F2F2F2;
}

.copy-code-button:focus {
    /* Avoid an ugly focus outline on click in Chrome,
       but darken the button for accessibility.
       See https://stackoverflow.com/a/25298082/1481479 */
    background-color: #E6E6E6;
    outline: 0;
}

.copy-code-button:active {
    background-color: #D9D9D9;
}

.highlight-rouge pre {
    /* Avoid pushing up the copy buttons. */
    margin: 0;
}
</style>

## On-premise Exchange

Adding Send-As rights

~~~ powershell
get-user -identity “MAILBOX_NAME” | Add-ADPermission -User “USER_ACCOUNT” -ExtendedRights Send-As
~~~

Setting maximum number of active sync devices. Typically this only comes up if you're sharing an account across a fair number of devices.

~~~ powershell
Get-ThrottlingPolicy
Set-ThrottlingPolicy –EASMaxDevices 25 –Identity DefaultThrottlingPolicy_XXXXXXXXX
~~~

Exporting mailboxes directly to PST. You only need to assign Management Role Assignment once per admin account.

~~~ powershell
New-ManagementRoleAssignment -Role "Mailbox Import Export" -User "ADMIN_ACCOUNT"
New-MailboxExportRequest -Mailbox MAILBOX_NAME -FilePath \\ServerName\pst\username.pst
Get-MailboxExportRequest
~~~

Finding emails by email address

~~~ powershell
get-transportserver | Get-MessageTrackingLog -Start "1/01/2017 12:00:00 am" -End "2/21/2017 17:30:00 pm" -resultsize unlimited |where-object {$_.Recipients -like "user@example.com" -AND $_.EventId -eq "receive"}
Get-MessageTrackingLog -Sender "user@example.com" -Recipients "user@example.com" -Start "1/19/2015 8:00AM" | FL Sender,Recipients,MessageSubject,MessageId
~~~

Setting up email forwarding

~~~ powershell
Set-MailboxAutoReplyConfiguration -identity USER_NAME -AutoReplyState enabled -ExternalAudience all -InternalMessage "Internal out of office message." -ExternalMessage "External out of office message."
Set-Mailbox USER_NAME -ForwardingAddress USER_NAME -DeliverToMailboxAndForward $True
~~~

Getting list of all the mailboxes and find the mailbox size

~~~ powershell
$Mailboxes = Get-Mailbox -ResultSize 200
foreach ($Mailbox in $Mailboxes)
{
$Mailbox | Add-Member -MemberType "NoteProperty" -Name "MailboxSizeMB" -Value ((Get-MailboxStatistics $Mailbox).TotalItemSize.Value.ToMb())
}
$Mailboxes | Sort-Object MailboxSizeMB -Desc | Select DisplayName, Alias, PrimarySMTPAddress, MailboxSizeMB | Export-Csv -NoType "C:\Temp\Mailboxes.csv"
~~~


## O365 Powershell commands

Updating O365 time zone and language in bulk

~~~ powershell
$credential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid?DelegatedOrg=TENANTDOMAIN.onmicrosoft.com -Credential $credential -Authentication Basic -AllowRedirection
Import-PSSession $Session
# Set all mailboxes to en-US, EST
get-mailbox | Set-MailboxRegionalConfiguration -Language 1033 -TimeZone "Eastern Standard Time"
# Find all mailboxes that match
get-mailbox -filter {EmailAddresses -like '*example.net*'} | Get-MailboxRegionalConfiguration
get-mailbox -filter {EmailAddresses -like '*bob*'} | Get-MailboxRegionalConfiguration
# Set a mailbox to en-US, EST
get-mailbox -filter {EmailAddresses -like '*bob*'} | Set-MailboxRegionalConfiguration -Language 1033 -TimeZone "Eastern Standard Time"
~~~

Changing user name. Usually needed if AD Sync is being wonky, which is fairly common.

~~~ powershell
$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential
Set-MsolUserPrincipalName -UserPrincipalName olduser24912@example.com -NewUserPrincipalName olduser@example.com
~~~

Copying membership from a hybrid group to a cloud only group.

~~~ powershell
$credential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid?DelegatedOrg=TenantDomainNameHere.onmicrosoft.com -Credential $credential -Authentication Basic -AllowRedirection
Import-PSSession $Session
$OldMembers = (Get-DistributionGroupMember "ExampleGrpHere").Name
New-DistributionGroup Cloud-ExampleGrpHere -Type Distribution -Members $OldMembers
~~~

## Windows Powershell commands

Running updates on a new PC

~~~ powershell
Powershell.exe -ExecutionPolicy Unrestricted
Install-Module PSWindowsUpdate
Get-WindowsUpdate
Install-WindowsUpdate
Restart-Computer
~~~

Reassociate PC to domain without reboot

~~~ powershell
Test-ComputerSecureChannel -credential DOMAIN\AdminAccount -Repair
~~~