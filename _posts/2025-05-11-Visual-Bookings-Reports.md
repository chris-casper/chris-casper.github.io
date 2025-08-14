---
title: "Infor Visual - Bookings Reports"
excerpt: "Keeping track of new and changed orders"
last_modified_at: 2025-05-11 20:00:00
tags:
  - Infor
  - Infor Visual
  - SQL
---

## Visual Bookings

Our sales folks want to keep track of both new orders and changes. We want to "book" the changes to the day they're made. 

Bookings reports themselves are half easy and half a pain in the neck. Checking for new customer orders is pretty easy. You can just use the CREATE_DATE from customer_order table. 

But if you want to track changes to existing orders, it gets a bit more tricky but there is a handy auditing feature built into Infor Visual.


## Auditing

Fire up Visual, go to Admin menu, click on Audit Maintenance

![Audit Maint](/images/posts/booking/bookings03.png)

Right click on any entry, click on "Configure Auditing"

![Audit Maint](/images/posts/booking/bookings02.png)

Go to CUST_ORDER_LINE, turn on UNIT_PRICE and ORDER_QTY. Plus anything else you want to monitor. 


![Audit Maint](/images/posts/booking/bookings01.png)

All of the data will be recorded to HISTORY_DATA table. Be careful how much is recorded, less is more. And purge the records as needed. Since both are on the history table and neatly timestamped there, I stuck to using that table for new customer orders as well as the changes. 

INSERT means new customer order.
UPDATE means changed customer order.


## Code explanation

The problem with the auditing table is that the table name, column name, etc are all separate rows. Piecing them back together into single rows can be a bit of a pain. The primary key for customer orders is pretty easy with just a tilde (~) between the customer order number and line number. You just need to do a LEFT and RIGHT to work with it. Other tables being audited can have a bit more unpleasant primary keys to parse. 

I left the parameters as SSRS code, but fixed date parameters are available. Just be sure to grab both. 

To assemble the data, I used a CTE, which creates a virtual table ChangeData. This was to consolidate rows that are changes to customer orders. The not great part is needing to use MAX, which I was worried would skew the data. So far it hasn't and the numbers look accurate. Then a select statement grabs the changes, and it gets added via UNION to the new orders. 



## Code


```sql
USE PFI10;


-- ==============================================
-- 1. Changes to ORDER_QTY and/or UNIT_PRICE
-- ==============================================
WITH ChangeData AS (
	SELECT
		CAST(hd.CREATE_DATE AS DATE) AS ChangeDate,
		LEFT(hd.PRIMARY_KEY, CHARINDEX('~', hd.PRIMARY_KEY) - 1) AS CustOrderID,
		TRY_CAST(RIGHT(hd.PRIMARY_KEY, LEN(hd.PRIMARY_KEY) - CHARINDEX('~', hd.PRIMARY_KEY)) AS INT) AS Line_No,
		MAX(CASE WHEN hd.COL_NAME = 'ORDER_QTY' THEN TRY_CAST(hd.OLD_VALUE AS FLOAT) END) AS OldQty,
		MAX(CASE WHEN hd.COL_NAME = 'ORDER_QTY' THEN TRY_CAST(hd.NEW_VALUE AS FLOAT) END) AS NewQty,
		MAX(CASE WHEN hd.COL_NAME = 'UNIT_PRICE' THEN TRY_CAST(hd.OLD_VALUE AS FLOAT) END) AS OldPrice,
		MAX(CASE WHEN hd.COL_NAME = 'UNIT_PRICE' THEN TRY_CAST(hd.NEW_VALUE AS FLOAT) END) AS NewPrice
	FROM HISTORY_DATA hd
	WHERE 
		hd.TBL_NAME = 'CUST_ORDER_LINE'
		AND hd.ACTION = 'UPDATE'
		AND hd.COL_NAME IN ('ORDER_QTY', 'UNIT_PRICE')
		--AND CAST(hd.CREATE_DATE AS DATE) >= '2025-05-01'
		AND ( 
			(CAST(hd.CREATE_DATE AS DATE) >= @StartDate) AND (CAST(hd.CREATE_DATE AS DATE) <= @EndDate)
			)
	GROUP BY 
		CAST(hd.CREATE_DATE AS DATE),
		hd.PRIMARY_KEY
)
SELECT
	cd.ChangeDate AS CREATE_DATE,
	'Change - Qty or Price' AS BookingType,
	col.PART_ID,
	c.name,
	col.LINE_STATUS,
	col.DESIRED_SHIP_DATE,
	cd.CustOrderID,
	cd.Line_No,
	ISNULL(cd.NewQty - cd.OldQty, 0) AS Qty,
	ISNULL(cd.NewPrice, col.UNIT_PRICE) AS UNIT_PRICE,
	-- Value Change
	(ISNULL(cd.NewQty, col.ORDER_QTY) * ISNULL(cd.NewPrice, col.UNIT_PRICE)) 
	  - (ISNULL(cd.OldQty, col.ORDER_QTY) * ISNULL(cd.OldPrice, col.UNIT_PRICE)) AS TotalAmt
FROM ChangeData cd
INNER JOIN CUST_ORDER_LINE col
	ON col.CUST_ORDER_ID = cd.CustOrderID AND col.LINE_NO = cd.Line_No
INNER JOIN CUSTOMER_ORDER as co
	ON col.cust_order_id = co.id
INNER JOIN CUSTOMER as c
	ON co.CUSTOMER_ID = c.ID
WHERE 
	-- Only include records with an actual change
	(ISNULL(cd.NewQty - cd.OldQty, 0) <> 0 OR ISNULL(cd.NewPrice - cd.OldPrice, 0) <> 0)
UNION ALL
-- ======================================
-- 2. New Bookings (INSERT on ORDER_QTY)
-- ======================================
SELECT  
	CAST(hd.CREATE_DATE AS DATE) AS CREATE_DATE,
	'New Order' AS BookingType,
	col.PART_ID,
	c.name,
	col.LINE_STATUS,
	col.DESIRED_SHIP_DATE,
	LEFT(hd.PRIMARY_KEY, CHARINDEX('~', hd.PRIMARY_KEY) - 1) AS CustOrderID,
	TRY_CAST(RIGHT(hd.PRIMARY_KEY, LEN(hd.PRIMARY_KEY) - CHARINDEX('~', hd.PRIMARY_KEY)) AS INT) AS Line_No,
	TRY_CAST(hd.NEW_VALUE AS FLOAT) AS Qty,
	col.UNIT_PRICE,
	TRY_CAST(hd.NEW_VALUE AS FLOAT) * col.UNIT_PRICE AS TotalAmt
FROM HISTORY_DATA AS hd
INNER JOIN CUST_ORDER_LINE AS col
	ON col.CUST_ORDER_ID = LEFT(hd.PRIMARY_KEY, CHARINDEX('~', hd.PRIMARY_KEY) - 1) 
	AND col.LINE_NO = TRY_CAST(RIGHT(hd.PRIMARY_KEY, LEN(hd.PRIMARY_KEY) - CHARINDEX('~', hd.PRIMARY_KEY)) AS INT)
INNER JOIN CUSTOMER_ORDER as co
	ON col.cust_order_id = co.id
INNER JOIN CUSTOMER as c
	ON co.CUSTOMER_ID = c.ID
WHERE 
	hd.TBL_NAME = 'CUST_ORDER_LINE'
	AND hd.ACTION = 'INSERT'
	AND hd.COL_NAME = 'ORDER_QTY'
	--AND CAST(hd.CREATE_DATE AS DATE) >= '2025-05-01'
	AND ( 
			(CAST(hd.CREATE_DATE AS DATE) >= @StartDate) AND (CAST(hd.CREATE_DATE AS DATE) <= @EndDate)
			)

ORDER BY
	c.name asc,
	BookingType DESC,
	CREATE_DATE DESC;
```

## Final thoughts

So far this seems to be working fine on every example we've checked. If we need to go overboard on this, it'll probably be setting up another table and a database trigger to keep track of CO changes outside of the Visual audit mechanism. 


## Attribution

If you wish to use this guide internally, just maintain attribution/copyright with a link to this article. 
Original link: https://casper.im/Visual-Queries/