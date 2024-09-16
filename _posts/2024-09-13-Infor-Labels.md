---
title: "Infor Visual - Label Printing Part 1"
excerpt: "Getting your label definitions"
last_modified_at: 2024-08-13 20:00:00
tags:
  - Infor
  - Infor Visual
  - SQL
  - Programming
---



## Prereq

Fire up SQL Server Management Studio and connect to the SQL server hosting your Visual instance.

To access label stuff in Visual 10, go to Admin menu on main screen, then Label Printer Setup Utility

## Finding all your labels

You can find all of your existing labels in LABEL_FORMAT table

```sql
use Visual_10_DB;
select * from LABEL_FORMAT
```

You can find your label groups in LABEL_GROUP and LABEL_GROUP_LINE. 


## Getting your label fields

Pick the label you want to use from previous query and add it to this query. Let's assume the label is called V10-Shipping-Example

```sql
use Visual_10_DB;
select COLUMN_ID from LABEL_FORMAT_FIELD
where LABEL_FORMAT_ID = 'V10-Shipping-Example'
```

## Recreating your label info 

Let's supposed the shipping label is for pack lists. 

Slap the fields from the previous query into the field list of this query. I'm using the Visual table shorthand, so it should copy/paste neatly. 

```sql
use Visual_10_DB;

select distinct

-- START PASTE AREA

COL.CUSTOMER_PART_ID
,COL.MISC_REFERENCE
,SL.PACKLIST_ID
,CO.CUSTOMER_PO_REF
,T.ID

--- END PASTE AREA


from shipper as s
INNER JOIN customer_order as co
	ON s.cust_order_id = co.id
INNER JOIN cust_address as ca
	ON co.customer_id = ca.customer_id
INNER JOIN cust_order_line as col
	ON s.cust_order_id = col.cust_order_id
INNER JOIN customer as c
	ON co.customer_id = c.id
INNER JOIN part as p
	ON col.part_id = p.id
INNER JOIN part_site as PST
	ON col.part_id = pst.part_id
INNER JOIN shipper_line as sl
	ON s.packlist_id = sl.packlist_id
INNER JOIN TRACE_INV_TRANS as ti
	ON sl.transaction_id = ti.transaction_id
INNER JOIN trace as t
	ON ti.trace_id = t.id

where s.packlist_id = 'PL001'
```

Any SHP TRACEABLE label type will work. And most other label types should be very trivial modification off this. Remember to use the same shorthand table names as Visual. 