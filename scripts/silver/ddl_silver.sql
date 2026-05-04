/*
=================================================================================
DDL Script: Create Silver Tables
=================================================================================
Script Purpose:
     This script creates tables in the 'silver' schema, dropping existing tables
     if they already exist.
     Run this script to re-define the DDL structure of 'silver' Tables
=================================================================================
*/

if object_id('silver.crm_cust_info', 'U') is not null
  drop table silver.crm_cust_info;
go
create table silver.crm_cust_info (
 cst_id               int,
 cst_key              nvarchar(50),   
 cst_firstname        nvarchar(50),
 cst_lastname         nvarchar(50),
 cst_marital_status   nvarchar(50),
 cst_gndr             nvarchar(50), 
 cst_create_date      date 
);
go 


if object_id('silver.crm_prd_info', 'U') is not null
  drop table silver.crm_prd_info;
go
create table silver.crm_prd_info (
 prd_id               int,
 prd_key              nvarchar(50),   
 prd_nm               nvarchar(50),
 prd_cost             nvarchar(50),
 prd_line_status      nvarchar(50),
 prd_start_dt         nvarchar(50), 
 prd_end_dt           date 
);
go 


if object_id('silver.crm_sales_details', 'U') is not null
  drop table silver.crm_sales_details;
go
create table silver.crm_sales_details (
 sls_ord_num          nvarchar(50),
 sls_prd_key          nvarchar(50),   
 sls_cust_id          int,
 sls_order_dt         int,
 sls_ship_dt          int,
 sls_due_dt           int, 
 sls_sales_dt         int,
 sls_quantity         int,
 sls_price            int,
);
go 


if object_id('silver.erp_CUST_AZ12', 'U') is not null
  drop table silver.erp_CUST_AZ12;
go
create table silver.erp_CUST_AZ12 (
 CID          nvarchar(50),
 BDATE        date,   
 GEN          nvarchar(50), 
);
go 


if object_id('silver.erp_LOC_A101', 'U') is not null
  drop table silver.erp_LOC_A101;
go
create table silver.erp_LOC_A101 (
 CID          nvarchar(50),
 CNTRY        nvarchar(50),  
);
go 


if object_id('silver.erp_PX_CAT', 'U') is not null
  drop table silver.erp_PX_CAT;
go
create table silver.erp_PX_CAT (
 ID            nvarchar(50),
 CAT           nvarchar(50),
 SUBCAT        nvarchar(50),  
 MAINTENANCE   nvarchar(50), 
);
go 
