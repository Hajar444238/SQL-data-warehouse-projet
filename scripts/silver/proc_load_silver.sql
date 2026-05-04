/*
====================================================================================
Stored Procedure: Load Silver Layer (Source -> Silver)
====================================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze schema.'
  Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into silver tables.

Parameters:
   None.
   This stored procedure does not accept any parameters or return any values.

Usage Example:
   exec bronze.load_silver;
====================================================================================
*/
create or alter procedure silver.load_silver as 
begin
   declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
   begin try
    set @batch_start_time = getdate()
	print '===============================================';
	print 'Loading Silver Layer';
	print '===============================================';

	print '-----------------------------------------------';
	print 'Loading CRM Tables ';
	print '-----------------------------------------------';

	set @start_time = getdate();
    print '>>Truncating table: silver.crm_cust_info';
    truncate table silver.crm_cust_info;
    print '>> Inserting data into: silver.crm_cust_info';
    insert into silver.crm_cust_info (
       cst_id, 
       cst_key, 
       cst_firstname, 
       cst_lastname, 
       cst_marital_status, 
       cst_gndr, 
       cst_create_date
    )

    select 
    cst_id, 
    cst_key,
    trim(cst_firstname) as cst_firstname,
    trim(cst_lastname) as cst_lastname,

    case when upper(trim(cst_marital_status)) = 'S' then 'Single'
         when upper(trim(cst_marital_status)) = 'M' then 'Married'
         else 'n/a'
    end cst_marital_status,

    case when upper(trim(cst_gndr)) = 'F' then 'Female'
         when upper(trim(cst_gndr)) = 'M' then 'Male'
         else 'n/a'
    end cst_gndr,

    cst_create_date
    from ( 
       select * ,
       row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
       from bronze.crm_cust_info
       where cst_id is not null 
    )t 
    where flag_last = 1
    set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	set @start_time = getdate();
    --crm_prd_info transformation 
    print '>>truncating table: silver.crm_prd_info';
    truncate table silver.crm_prd_info;
    print '>> Inserting data into: silver.crm_prd_info';
    insert into silver.crm_prd_info (
       prd_id,
       cat_id,
       prd_key,
       prd_nm,
       prd_cost,
       prd_line_status,
       prd_start_dt,
       prd_end_dt
    )
    select 
    prd_id,
    replace(substring(prd_key, 1, 5), '-', '_' ) as cat_id,
    substring(prd_key, 7, len(prd_key)) as prd_key,
    prd_nm,
    isnull(prd_cost, 0) as prd_cost,
    case upper(trim(prd_line_status))
         when 'M' then 'Moutain'
         when 'R' then 'Road'
         when 'S' then 'other Sales'
         when 'T' then 'Touring'
         else 'n/a'
    end as prd_line_status,
    cast (prd_start_dt as date) as prd_start_dt,
    --cast(lead (prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
    DATEADD(DAY, -1,
        LEAD(CAST(prd_start_dt AS DATE)) 
        OVER (PARTITION BY prd_key ORDER BY CAST(prd_start_dt AS DATE))
    ) as prd_end_dt
    from bronze.crm_prd_info 
    set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	set @start_time = getdate();

    --crm_sales_details transformation 
    print '>>truncating table: silver.crm_sales_details';
    truncate table silver.crm_sales_details;
    print '>> Inserting data into: silver.crm_sales_details';
    insert into silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    select 
       sls_ord_num,
       sls_prd_key,
       sls_cust_id,
       case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null 
            else cast(cast(sls_order_dt as varchar) as date)
       end as sls_order_dt,
       case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null 
            else cast(cast(sls_ship_dt as varchar) as date)
       end as sls_ship_dt,
       case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null 
            else cast(cast(sls_due_dt as varchar) as date)
       end as sls_due_dt,
       case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
              then sls_quantity * abs(sls_price)
           else sls_sales
      end as sls_sales,   
      sls_quantity,
      case when sls_price is null or sls_price <= 0
              then sls_sales / nullif(sls_quantity, 0) 
         else sls_price
      end as sls_price
    from bronze.crm_sales_details

    set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	print '------------------------------';
	print 'Loading ERP Tables ';
	print '------------------------------';

	set @start_time = getdate();

    --erp_CUST_AZ12 transformation 
    print '>>truncating table: silver.erp_CUST_AZ12';
    truncate table silver.erp_CUST_AZ12;
    print '>> Inserting data into: silver.erp_CUST_AZ12';
    insert into silver.erp_CUST_AZ12 (
          CID,
          BDATE,
          GEN)
    select 
    case when CID like 'NAS%' then substring(CID, 4, len(CID))
         else CID
    end as CID,
    case when BDATE > getdate() then null
         else BDATE
    end as BDATE,
    case when upper(trim(gen)) in ('F', 'Female') then 'Female'
         when upper(trim(gen)) in ('M', 'Male') then 'Male'
         else 'n/a'
    end as GEN
    from bronze.erp_CUST_AZ12

    set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	set @start_time = getdate();



    --erp_LOC_A10 transformation
    print '>>truncating table: silver.erp_LOC_A101';
    truncate table silver.erp_LOC_A101;
    print '>> Inserting data into: silver.erp_LOC_A101';
    insert into silver.erp_LOC_A101(
    CID, CNTRY)
    select 
    replace(CID, '-', '')CID,
    case when trim(CNTRY) = 'DE' then 'Germaby'
         when trim(CNTRY) in ('us', 'USA') then 'Unitaed States'
         when trim(CNTRY) = '' or CNTRY is null then 'n/a'
         else trim(CNTRY)
    end as CNTRY
    from bronze.erp_LOC_A101

    set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	set @start_time = getdate();


    --no transformation needed (erp_PX_CAT_G1V2)
    print '>>truncating table: silver.erp_PX_CAT_G1V2';
    truncate table silver.erp_PX_CAT_G1V2;
    print '>> Inserting data into: silver.erp_PX_CAT_G1V20';
    insert into silver.erp_PX_CAT_G1V2(
           ID,
           CAT,
           SUBCAT,
           MAINTENANCE)
    select ID,
           CAT,
           SUBCAT,
           MAINTENANCE
    from bronze.erp_PX_CAT_G1V2

    set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	set @batch_end_time = getdate();
    print '==========================================='
	print 'loading Silver layer is completed';
	print '     -Total load duration: '+ cast(datediff(second, @batch_start_time, @batch_start_time) as nvarchar) + 'seconds';
    print '==========================================='

   end try
   begin catch
      print '==========================================='
	  print 'ERROR OCCURED DURING LOADING BRONZE LAYER'
	  print 'Error Message' + ERROR_MESSAGE();
	  print 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
	  print 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
	  print '==========================================='

   end catch
end 
