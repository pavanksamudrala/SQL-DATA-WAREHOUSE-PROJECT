CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
 DECLARE @StartTime DATETIME , @EndTime DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
  BEGIN TRY
  SET @batch_start_time = GETDATE();
     PRINT '======================';
     PRINT ' LOADING BRONZE LAYER';
     PRINT '======================';

     PRINT '----------------------';
     PRINT ' Loading CRM Tables ';
     PRINT '----------------------';

        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info
        PRINT '>> Inserting Data INTO : bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\PK\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
               FIRSTROW = 2,
               FIELDTERMINATOR = ',',
               CODEPAGE = '65001',
               TABLOCK
               );
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '-----------------------------';
    
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info
        PRINT '>> Inserting Data INTO : bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\PK\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
               FIRSTROW = 2,
               FIELDTERMINATOR = ',',
               CODEPAGE = '65001',
               TABLOCK
               );
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '-----------------------------';
    
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details
        PRINT '>> Inserting Data INTO : bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\PK\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
               FIRSTROW = 2,
               FIELDTERMINATOR = ',',
               CODEPAGE = '65001', 
               TABLOCK
               );
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '-----------------------------';
    
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12
        PRINT '>> Inserting Data INTO : bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\PK\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
               FIRSTROW = 2,
               FIELDTERMINATOR = ',',
               CODEPAGE = '65001',
               TABLOCK
               );
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '------------------------------';
    
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101
        PRINT '>> Inserting Data INTO : bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\PK\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
               FIRSTROW = 2,
               FIELDTERMINATOR = ',',
               CODEPAGE = '65001',
               TABLOCK
               );
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '-----------------------------';
    
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2
        PRINT '>> Inserting Data INTO : bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\PK\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,           
            CODEPAGE = '65001',        
            TABLOCK
        );
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
  SET @batch_end_time = GETDATE();
  PRINT '-----------------------------';
  PRINT '====================================';
  PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(Second, @batch_start_time, @batch_end_time) AS NVARCHAR)+ 'Seconds';  
  PRINT '====================================';
  END TRY 
  BEGIN CATCH
  PRINT '=========================================';
  PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
  PRINT 'Error Message' + ERROR_MESSAGE();
  PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
  PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
  PRINT '=========================================';
  END CATCH
END
