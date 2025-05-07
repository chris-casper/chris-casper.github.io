---
title: "Infor Visual - Finding the ERP Queries"
excerpt: "How to find the query for anything Infor Visual ERP does"
last_modified_at: 2024-12-29 20:00:00
tags:
  - Infor
  - Infor Visual
  - SQL
---

## Visual Bookings

Bookings reports are half easy and half a pain in the neck. Checking for new customer orders is pretty easy. You can just use the CREATE_DATE from customer_order table. 

But if you want to track changes to existing orders, it gets a bit more tricky but there is a handy auditing feature built into Infor Visual.


## Auditing

Fire up Visual, go to Admin menu, click on Audit Maintenance

![Audit Maint](/images/posts/booking/bookings03.png)

Right click on any entry, click on "Configure Auditing"

![Audit Maint](/images/posts/booking/bookings02.png)

Go to CUST_ORDER_LINE, turn on UNIT_PRICE and ORDER_QTY. Plus anything else you want to monitor. 

INSERT means new customer order.

![Audit Maint](/images/posts/booking/bookings01.png)

All of the data will be recorded to HISTORY_DATA table. Be careful how much is recorded, less is more. And purge the records as needed.


## Code

## Attribution

If you wish to use this guide internally, just maintain attribution/copyright with a link to this article. 
Original link: https://casper.im/Visual-Queries/