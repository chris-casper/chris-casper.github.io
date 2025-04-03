---
title: "Infor Visual - Finding the ERP Queries"
excerpt: "How to find the query for anything Infor Visual ERP does"
last_modified_at: 2024-12-29 20:00:00
tags:
  - Infor
  - Infor Visual
  - SQL
---

## Visual ERP queries

Suppose you have a report in Visual that you'd like to port to SSRS or use for automation. If you ask Infor, they will decline to provide any code. 

But! You can snag it directly off the server. 

Infor Visual doesn't really have a server, the clients work by talking to the SQL or Oracle server directly. Almost everything is stored in the DB. The exception being the client config files, but I'm told those are moving to the DB as well as they make it more cloud/web oriented. 

The nice part, that means you can easily reverse engineer anything Visual does. Using a tool that you get with your DB server. I'll be sticking to Microsoft SQL.

The annoying part, their queries suck. They basically grab one thing at a time and combine them in the program. It's very inefficient, and why latency is super critical with Infor Visual performance tuning. 10 Gigabit fiber is definitely your friend, for the latency not the speed. So if you want to be efficient, snag all the queries and re-write them with proper joins for much much faster reports. Still saves a bunch of time, but it's an annoying quirk. Hopefully they change that behavior with their new REST model in Infor Visual 11.


## SQL Server Profiler

Fire up the Visual client. It can be on any machine. I recommend logging into your Visual PLAY or DEV environment rather than LIVE environment, keeps down the noise and it's easier to find the query you want. You can use any username, but I recommend going with SYSADM. 

![Profiler](/images/posts/VQ/Profiler.PNG)

Fire up SQL Server Profiler. To keep it simple, log into the SQL Server running your Visual instance. It'll be under Microsoft SQL Server Tools folder, and should be installed when you install SQL. You can use any SQL admin account with full rights, but I just stick with sa account.

Go to File -> New Trace

![New Capture](/images/posts/VQ/New-Capture.PNG)

You can leave the trace name alone, click on the Events Selection tab on the top right

![Trace types](/images/posts/VQ/Trace-types.PNG)

Unselect everything but SQL:BatchCompleted

![Filters](/images/posts/VQ/Filter.PNG)

Click on the Column Filters button in the lower right

Clickon LoginName. Click on LIKE and enter "SYSADM". Hit OK

Click Run. You'll now see items scrolling down. Go back to Visual client and do whatever you're looking to capture. Once you've run the report or looked up something in Part Maintenance, click on the pause icon in SQL Server Profiler on the tool bar. 


## The Results

![Results](/images/posts/VQ/Results.PNG)

Everything you want is under "Visual Enterprise".

Here you'll have to look through the results to find the queries you want. You'll have to have SQL knowledge to figure out the results. You can ignore "SET FMTONLY ON", "where 1=2" and "SET FMTONLY OFF".

Reports tend to have one or few queries. Visual programs on the other hand tend to have clusters of queries.

Unfortunately I'll have to skip details on interpreting the results. Infor sent me an angry email over my previous posts, claiming I had posted their propriety code. They went away when I pointed out it was my code. The SQL queries are their property, so I can't post them. But I can show you have to get them yourself.


## Attribution

If you wish to use this guide internally, just maintain attribution/copyright with a link to this article. 
Original link: https://casper.im/Visual-Queries/s