/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
     This script performs various checks for data consistency, accuracy, 
     and standarisation across the 'silver' schemas. It includes checks for:
     - Null or duplicate primary keys.
     - Unwanted spaces in string fields.
     - Data standarisation and consistency.
     - Invalid date ranges and orders.
     - Data consistency between related fields.

Usage Notes:
     - Run these checks after data loading silver layer.
     - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/


--===============================================================================
-- Checking 'silver.crm_cust_info'
--===============================================================================
-- check for nulls or duplicates in primary kay
SELECT cst_id , count(*) 
from silver.crm_cust_info
group by cst_id
having count(*)>1 or cst_id is null
  
select *,
row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
from silver.crm_cust_info

--check of unwanted spaces
select cst_firstname
from silver.crm_cust_info 
where cst_firstname != trim(cst_firstname)

select cst_lastname
from silver.crm_cust_info 
where cst_lastname != trim(cst_lastname)
  
--data standarisation & consistency
select distinct cst_gndr
from silver.crm_cust_info

select distinct cst_marital_status
from silver.crm_cust_info

  
--===============================================================================
-- Checking 'silver.crm_prd_info'
--===============================================================================
---- check for nulls or duplicates in primary kay
select prd_id , count(*)
from silver.crm_prd_info
group by prd_id
having count(*)>1 or prd_id is null

--check of unwanted spaces
select prd_nm
from silver.crm_prd_info 
where prd_nm != trim(prd_nm)

--ckeck for nulls or negative numbers
select prd_cost
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null 

--data standarisation & consistency
select distinct prd_line_status 
from silver.crm_prd_info

--in order to kno the meaning of the abreviation i should ask the expert form the source system 
--check for invalid date orders
select * 
from silver.crm_prd_info
where prd_end_dt < prd_start_dt

--changing prd_start_dt type 
/* 
ALTER TABLE bronze.crm_prd_info
ALTER COLUMN prd_start_dt date;
*/

  
--===============================================================================
-- Checking 'silver.crm_sales _details'
--=============================================================================== 
select 
   sls_ord_num,
   sls_prd_key,
   sls_cust_id,
   sls_order_dt,
   sls_ship_dt,
   sls_due_dt,
   sls_sales,
   sls_quantity,
   sls_price
from silver.crm_sales_details
--where sls_cust_id not in (select cst_id from silver.crm_cust_info)
where sls_prd_key not in (select prd_key from silver.crm_prd_info)

---- check for invalid dates
select nullif(sls_order_dt, 0) sls_order_dt
from silver.crm_sales_details
where sls_order_dt <= 0  or len(sls_order_dt) != 8

select nullif(sls_ship_dt, 0) sls_ship_dt
from silver.crm_sales_details
where sls_ship_dt <= 0  
or len(sls_ship_dt) != 8
or sls_ship_dt > 20500101
or sls_ship_dt < 19000101

select nullif(sls_due_dt, 0) sls_due_dt
from silver.crm_sales_details
where sls_due_dt <= 0  
or len(sls_due_dt) != 8
or sls_due_dt > 20500101
or sls_due_dt < 19000101

--check for invalid date orders
select * from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

--check data consistency : between sales, quantity and price
-- sales=quantity * price
-- values must not be null , zero or negative

select  distinct sls_sales, sls_quantity, sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null 
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
order by sls_sales, sls_quantity, sls_price


--===============================================================================
-- Checking 'silver.erp_CUST_AZ12'
--=============================================================================== 
select CID, BDATE, GEN 
from silver.erp_CUST_AZ12

-- check for duplicates or null cid 
select CID , count(*)
from bronze.erp_CUST_AZ12
group by CID
having count(*)>1 or CID is null

--check for cid invalid spaces 
select CID from bronze.erp_CUST_AZ12
where trim(CID) != CID 

--check for cid invalid dates
select BDATE from bronze.erp_CUST_AZ12
where BDATE is null 

select distinct BDATE
from bronze.erp_CUST_AZ12
where BDATE > getdate()

--check for gen invalid spaces 
select GEN from bronze.erp_CUST_AZ12
where trim(GEN) != GEN or GEN is null 

--see all possible values 
select distinct GEN from bronze.erp_CUST_AZ12


--===============================================================================
-- Checking 'silver.erp_LOC_A101'
--=============================================================================== 
select CID, CNTRY from bronze.erp_LOC_A101
select distinct CID from bronze.erp_LOC_A101
select distinct CNTRY from silver.erp_LOC_A101
order by CNTRY


--===============================================================================
-- Checking 'silver.erp_PX_CAT_G1V2'
--=============================================================================== 
select ID,
       CAT,
       SUBCAT,
       MAINTENANCE
from bronze.erp_PX_CAT_G1V2

select distinct ID from bronze.erp_PX_CAT_G1V2

select distinct CAT from bronze.erp_PX_CAT_G1V2
order by CAT
select CAT from bronze.erp_PX_CAT_G1V2 where trim(CAT)!=CAT

select distinct SUBCAT from bronze.erp_PX_CAT_G1V2
order by SUBCAT
select SUBCAT from bronze.erp_PX_CAT_G1V2 where trim(SUBCAT)!=SUBCAT

select distinct MAINTENANCE from bronze.erp_PX_CAT_G1V2
select MAINTENANCE from bronze.erp_PX_CAT_G1V2 where trim(MAINTENANCE)!=MAINTENANCE










