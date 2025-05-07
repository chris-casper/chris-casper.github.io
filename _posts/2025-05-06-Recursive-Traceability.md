---
title: "Infor Visual - Recursive Traceability across Multiple Part Operations"
excerpt: "Material certifications, definitely an exciting topic"
last_modified_at: 2025-05-06 20:00:00
tags:
  - Infor Visual
  - SQL
---

## What's the problem?

Traceability can be a pain. With Infor Visual, you have to loop through the inventory transaction table, trace inventory transactions and trace table. Multiple times.  We wanted to be able to easily chain finished good trace numbers back to the raw material trace number. 

Basically, we need an unbroken chain of custody from the finished part sold to the end customer all the way back to the original mine.

Visual doesn't make that easy. It doesn't store trace numbers in any convenient fashion.


## Things get unweldy

You can manually code it if you know how many layers your part has. But in my case, I had a part with three stages of production but we were adding a fourth, with more possible. That racked up about 30 joins to brute force the solution. To make it more fun, we store the heat treat info with the raw material trace number as APROPERTY_1. 

SQL doesn't have built in recursion. But common table expression are a way to bypass that limitation. CTEs create a virtual tables with records and columns once executed. It's not a temp table that is somewhat persistant, it's created on runtime, not shared and gone once the query is finished. Temp tables can get goofy with reports, especially if it's rerun or multiple people may use the same report at the same time. 

## Tackling the problem

We first do a manual query to set a root trace ID. For our certification, we work off pack lists because shipping department generates them. It's possible to work off work orders, but requires more code. I use SSRS, so left @WhatPackList in as a variable, but you can hardcode in a pack list as well. Fortunately it links to the inventory transaction table via shipper line neatly.

I store the path in TracePath, useful for testing but disabled in production. But I created another report so users can easily see the path. This however had a real issue with recursive loops that took a bit to noodle around. I figured it out through trial and error, you wanted to avoid any path that would contain the second trace table ID.

Each step requires going through inventory transaction table twice. 

Once you have the final information, you can grab all the extra tables for ancillary info by linking to the virtual table.

You can also link in the work order as well as pack list if you have multiple raw material ID for the packlist. If you have multiple raw material ID's per work order and lot number, you have bigger problems. But you can probably work with this code to get a list. 


## Code


```sql


-- Recursive Trace 
--
--  Written by Chris Casper
--  v1 - 2025.05.06
--
--
--

WITH TraceCTE AS (
    -- Anchor: Start from finished good trace
    SELECT 
        t.ID AS TraceID,
        t.ID AS RootTraceID,
		t.APROPERTY_1 as HeatTreatNum,
        CAST(t.ID AS VARCHAR(MAX)) AS TracePath
    FROM 
        shipper s
        INNER JOIN shipper_line sl ON s.packlist_id = sl.packlist_id
        INNER JOIN TRACE_INV_TRANS ti ON sl.transaction_id = ti.transaction_id
        INNER JOIN TRACE t ON ti.trace_id = t.id
    WHERE 
        --s.packlist_id = 'PL012345'
	s.packlist_id = @WhatPackList

    UNION ALL

    -- Recursive: trace backwards but prevent revisiting a trace already in the path
    SELECT 
        t2.ID AS TraceID,
        tc.RootTraceID,
		t2.APROPERTY_1 as HeatTreatNum,
        CAST(tc.TracePath + ' <- ' + CAST(t2.ID AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS TracePath
    FROM 
        TraceCTE tc
        INNER JOIN TRACE_INV_TRANS ti1 ON tc.TraceID = ti1.TRACE_ID
        INNER JOIN INVENTORY_TRANS it1 ON ti1.TRANSACTION_ID = it1.TRANSACTION_ID
        INNER JOIN INVENTORY_TRANS it2 
            ON it1.WORKORDER_BASE_ID = it2.WORKORDER_BASE_ID
            AND it1.WORKORDER_LOT_ID = it2.WORKORDER_LOT_ID
            AND it2.TYPE = 'O'
            AND it2.CLASS = 'I'
        INNER JOIN TRACE_INV_TRANS ti2 ON it2.TRANSACTION_ID = ti2.TRANSACTION_ID
        INNER JOIN TRACE t2 ON ti2.TRACE_ID = t2.ID
    WHERE  -- Removing this will cause recursive loop
        tc.TracePath NOT LIKE '%' + CAST(t2.ID AS VARCHAR) + '%'
)
SELECT DISTINCT top 1

	-- Uncomment for whatever data you need
	
    --s.packlist_id as packlist_id
	--, it.PART_ID
    --, it.WORKORDER_BASE_ID as WORKORDER_BASE_ID
	tc.HeatTreatNum as LastHeatTreat  -- remember, we're getting value from CTE, not directly from table 
    --, tc.TraceID AS RelatedTraceID
	--, it.TRANSACTION_DATE

FROM 
    TraceCTE tc

    -- Link back to transactions and work orders
    LEFT JOIN TRACE_INV_TRANS ti ON tc.TraceID = ti.TRACE_ID
    LEFT JOIN INVENTORY_TRANS it ON ti.TRANSACTION_ID = it.TRANSACTION_ID

    -- Joins from original query for the misc data
    LEFT JOIN shipper_line sl ON ti.transaction_id = sl.transaction_id
    LEFT JOIN shipper s ON sl.packlist_id = s.packlist_id
    LEFT JOIN customer_order co ON s.cust_order_id = co.id
    LEFT JOIN cust_address ca ON co.customer_id = ca.customer_id AND co.SHIP_TO_ADDR_NO = ca.ADDR_NO
    LEFT JOIN SHIPTO_ADDRESS sa ON ca.SHIPTO_ID = sa.SHIPTO_ID
    LEFT JOIN cust_order_line col ON s.cust_order_id = col.cust_order_id
    LEFT JOIN customer c ON co.customer_id = c.id
    LEFT JOIN part p ON col.part_id = p.id
    LEFT JOIN part_site pst ON col.part_id = pst.part_id
--where 
	--it.PART_ID like 'RM-%'
	--it.WORKORDER_BASE_ID like 'X0123456'
	--it.WORKORDER_BASE_ID like @WhatWorkOrder
where 
	--(ti.QTY >= '0') 
	--OR 
	(tc.HeatTreatNum is not null) 


OPTION (MAXRECURSION 100);




```