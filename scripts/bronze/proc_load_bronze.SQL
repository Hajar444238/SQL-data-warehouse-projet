/*
====================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
====================================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the 'bulk insert' command to load data from csv Files to bronze tables.

Parameters:
   None.
 This stored procedure does not accept any parameters or return any values.

Usage Example:
   exec bronze.load_bronze
====================================================================================
*/

create or alter procedure bronze.load_bronze as
begin
   declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
   begin try
    set @batch_start_time = getdate()
	print '=============================';
	print 'Loading Bronze Layer';
	print '=============================';

	print '------------------------------';
	print 'Loading CRM Tables ';
	print '------------------------------';

	set @start_time = getdate();
	print '>> Truncating Table: bronze.crm_cust_info '
	truncate table bronze.crm_cust_info;

	print '>> Inserting data into: bronze.crm_cust_info'
	bulk insert bronze.crm_cust_info
	from 'C:\Users\HP\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
	with(   
	  firstrow = 2,
	  fieldterminator = ',',
	  tablock
	);
	set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	set @start_time = getdate();
	print '>> Truncating Table: bronze.crm_prd_info'
	truncate table bronze.crm_prd_info;

	print '>> Inserting data into: bronze.crm_prd_info'
	bulk insert bronze.crm_prd_info
	from 'C:\Users\HP\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
	with(
	  firstrow = 2,
	  fieldterminator = ',',
	  tablock
	);
	set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	set @start_time = getdate();
	print '>> Truncating Table: bronze.crm_sales_details'
	truncate table bronze.crm_sales_details;

	print '>> Inserting data into: bronze.crm_sales_details'
	bulk insert bronze.crm_sales_details
	from 'C:\Users\HP\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
	with(
	  firstrow = 2,
	  fieldterminator = ',',
	  tablock
	);
	set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	print '------------------------------';
	print 'Loading ERP Tables ';
	print '------------------------------';

	set @start_time = getdate();
	print '>> Truncating Table: bronze.erp_CUST_AZ12'
	truncate table bronze.erp_CUST_AZ12;

	print '>> Inserting data into: bronze.erp_CUST_AZ12'
	bulk insert bronze.erp_CUST_AZ12
	from 'C:\Users\HP\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
	with(
	  firstrow = 2,
	  fieldterminator = ',',
	  tablock
	);
	set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	set @start_time = getdate();
	print '>> Truncating Table: bronze.erp_LOC_A101'
	truncate table bronze.erp_LOC_A101;

	print '>> Inserting data into: bronze.erp_LOC_A101'
	bulk insert bronze.erp_LOC_A101
	from 'C:\Users\HP\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
	with(
	  firstrow = 2,
	  fieldterminator = ',',
	  tablock
	);
	set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	set @start_time = getdate();
	print '>> Truncating Table: bronze.erp_PX_CAT_G1V2'
	truncate table bronze.erp_PX_CAT_G1V2;

	print '>> Inserting data into: bronze.erp_PX_CAT_G1V2'
	bulk insert bronze.erp_PX_CAT_G1V2
	from 'C:\Users\HP\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
	with(
	  firstrow = 2,
	  fieldterminator = ',',
	  tablock
	);
	set @end_time = getdate();
	print '>> Load Duration: '+ cast (datediff(second,@start_time, @end_time) as nvarchar) + 'seconds';
	print '>>----------------';

	set @batch_end_time = getdate();
	print '=============================='
	print 'loading bronze layer is completed';
	print '     -Total load duration: '+ cast(datediff(second, @batch_start_time, @batch_start_time) as nvarchar) + 'seconds';
	print '=============================='

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
