---
title: "Nicelabel File Export"
excerpt: "Exporting files from Document Storage"
last_modified_at: 2025-04-03 20:00:00
tags:
  - NiceLabel
  - SQL
---

## Nicelabel 

Nicelabel is a bulk label software package. They have a storage system that uses WebDAV for accessing files from Print Stations, the label making software, etc. It's handy but I'm not sure why they didn't go with an SMB share. I'm assuming for access control. Rather than just locking down SMB NTFS permissions and performing file operations via ACL's within the software, maybe. 

The central file storage is controlled by "EPM", which is their web console. 

All and all, pretty decent so far.


## Problem

So a power user that works on the label layouts mucked up a file. I figured it wouldn't be too hard to recover the file because I am a bit nuts about backups. Two different independent backup systems and hourly backups. But... I had no idea where the files were physically stored. 

After looking around, I reached out to support. 

## Support

Nicelabel's second and third tier support are excellent. They know their stuff and are super helpful. 

They provided the info that the files are stored in the DB, not in flat files. And that the official guidance is to enable version control. But if you haven't turned that on, you'd need to restore the DB or fire up a virtual clone, restore the DB on that clone and export Nicelabel Designer from the clone. That sounds like work, so I went looking for a better solution.


## Exporting files from T-SQL 

This isn't uncommon. SSRS does the same thing. But there is a handy powershell command to export all of the files to RDL. I schedule it nightly. 

It's saved my bacon many times, and I always implement it when firing up a new SSRS instance. 


```powershell
# Install-Module -Name ReportingServicesTools
# OR
# Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/Microsoft/ReportingServicesTools/master/Install.ps1)


#Declare SSRS URI
$sourceRsUri = 'http://ssrs-server:8080/ReportServer/'

#Declare Proxy so we dont need to connect with every command
$proxy = New-RsWebServiceProxy -ReportServerUri $sourceRsUri

#Output ALL Catalog items to file system
Out-RsFolderContent -Proxy $proxy -RsFolder / -Destination 'C:\Backups\SSRS' -Recurse 
```

Originally I tried using BCP to export the files, but it's extremely picky. 

Microsoft 'solved' the issue by having FMT file that provides the settings for export. But if you don't know the settings, it doesn't go well. I learned a bit more about [PNG forensics](https://medium.com/@0xwan/png-structure-for-beginner-8363ce2a9f73) but ultimately gave up because it was taking too long, and I found a new really nice hex editor, [ImHex](https://imhex.werwolv.net/). BCP kept dumping 8 byte header in front of the real data. I could have done a hacky solution to chop those bytes but I wasn't thrilled. 

Nicelabel techs tried to be supportive, but didn't know the answer either. 

I got a hint from a [SQL blog](https://sqlrambling.net/2020/04/04/saving-and-extracting-blob-data-basic-examples/) about using OLE object creation. Honestly I should have coded it in powershell, but instead I just wrote the SQL and kick it off with powershell. Works well enough, and I'm scheduling for nightly. I checked all of the file types and they all seem to export cleanly. Someday I might clean it up and rewrite in native powershell. 

Nicelabel-File-Export.SQL:
```sql

-- Nicelabel - File Repository to Disk
--
--  Written by Chris Casper
--  v1 - 2025.04.03
--
--  Description:
--  Nicelabel stores all "Document Storage" files in T-SQL. If there is an issue with version control 
--  or a label somehow gets corrupted/changed, you would have to overwrite the entire DB to restore one 
--  label. This script dumps all files to flat file. 
--
--


-- Update if you changed the default Nicelabel DB name
USE NiceAN;
GO

-- Variables
DECLARE @Name NVARCHAR(255),
        @Data VARBINARY(MAX),
        @FilePath VARCHAR(MAX),
        @init INT;

DECLARE cur CURSOR FOR
SELECT Name, Content
FROM NiceAN.nan.DocumentStorageRepository;  -- This is a view, not a table

OPEN cur;

FETCH NEXT FROM cur INTO @Name, @Data;

-- Loop for entire table
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @FilePath = 'C:\Backups\NiceLabel\' + @Name;

    -- Create ADODB.Stream object
    EXEC sp_OACreate 'ADODB.Stream', @init OUTPUT;
    EXEC sp_OASetProperty @init, 'Type', 1; -- Binary mode
    EXEC sp_OAMethod @init, 'Open';
    EXEC sp_OAMethod @init, 'Write', NULL, @Data;
    EXEC sp_OAMethod @init, 'SaveToFile', NULL, @FilePath, 2; -- Overwrite if exists
    EXEC sp_OAMethod @init, 'Close';
    EXEC sp_OADestroy @init; -- Cleanup

    FETCH NEXT FROM cur INTO @Name, @Data;
END

CLOSE cur;
DEALLOCATE cur;
```