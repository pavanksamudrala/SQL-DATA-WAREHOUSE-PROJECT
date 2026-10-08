CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    /*
       Bronze layer ingestion procedure.
       This procedure loads raw CRM and ERP source files into the bronze schema.
       The bronze layer acts as the landing area for source data before cleansing,
       validation, and transformation into silver/gold layers.

       Flow of this procedure:
       1. Start a batch timer.
       2. Truncate each bronze table to remove stale data from the previous run.
       3. Bulk insert the latest CSV data file for that table.
       4. Log execution time for each table and for the overall batch.
       5. Catch and print any errors without failing silently.
    */

    DECLARE @StartTime DATETIME,
            @EndTime DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time DATETIME;

    BEGIN TRY
        -- Capture the beginning of the full bronze load batch.
        SET @batch_start_time = GETDATE();

        PRINT '======================';
        PRINT ' LOADING BRONZE LAYER';
        PRINT '======================';

        PRINT '----------------------';
        PRINT ' Loading CRM Tables ';
        PRINT '----------------------';

        -- ------------------------------------------------------------------
        -- CRM customer information table
        -- ------------------------------------------------------------------
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.crm_cust_info';

        -- Truncate removes all existing data so the table contains only the newest file load.
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data INTO : bronze.crm_cust_info';

        -- BULK INSERT loads large CSV files quickly into an SQL Server table.
        -- FIRSTROW = 2 skips the header row in the CSV file.
        -- FIELDTERMINATOR = ',' defines that values are separated by commas.
        -- CODEPAGE = '65001' ensures the file is read as UTF-8 (supports special characters).
        -- TABLOCK improves performance by taking a bulk update lock on the table during insert.
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

        -- ------------------------------------------------------------------
        -- CRM product information table
        -- ------------------------------------------------------------------
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.crm_prd_info';

        -- Truncate ensures no duplicate or stale product rows remain from earlier loads.
        TRUNCATE TABLE bronze.crm_prd_info;

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

        -- ------------------------------------------------------------------
        -- CRM sales details table
        -- ------------------------------------------------------------------
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.crm_sales_details';

        -- Clearing this table before load keeps the bronze layer aligned with the latest sales extract.
        TRUNCATE TABLE bronze.crm_sales_details;

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

        PRINT '----------------------';
        PRINT ' Loading ERP Tables ';
        PRINT '----------------------';

        -- ------------------------------------------------------------------
        -- ERP customer master table
        -- ------------------------------------------------------------------
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.erp_cust_az12';

        -- A full refresh keeps the ERP customer bronze table synchronized with the latest batch file.
        TRUNCATE TABLE bronze.erp_cust_az12;

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

        -- ------------------------------------------------------------------
        -- ERP location table
        -- ------------------------------------------------------------------
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.erp_loc_a101';

        -- The location table is also treated as a full refresh before each batch ingestion.
        TRUNCATE TABLE bronze.erp_loc_a101;

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

        -- ------------------------------------------------------------------
        -- ERP price category table
        -- ------------------------------------------------------------------
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table : bronze.erp_px_cat_g1v2';

        -- This prevents stale or partially loaded price category records from staying in bronze.
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

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

        -- Capture total batch time to help monitor ETL performance and detect slow loads.
        SET @batch_end_time = GETDATE();
        PRINT '-----------------------------';
        PRINT '====================================';
        PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(Second, @batch_start_time, @batch_end_time) AS NVARCHAR)+ 'Seconds';
        PRINT '====================================';
    END TRY
    BEGIN CATCH
        -- Catch block logs exceptions so failures are visible without stopping the rest of the process.
        PRINT '=========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================';
    END CATCH
END;
