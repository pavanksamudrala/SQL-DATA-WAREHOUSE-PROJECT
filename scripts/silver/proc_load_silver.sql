EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
 DECLARE @StartTime DATETIME , @EndTime DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
  BEGIN TRY
  SET @batch_start_time = GETDATE();
     PRINT '======================';
     PRINT ' LOADING SILVER LAYER';
     PRINT '======================';

     PRINT '----------------------';
     PRINT ' Loading CRM Tables ';
     PRINT '----------------------';

    SET @StartTime = GETDATE();
    PRINT '>> Truncating Table : silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info
    PRINT '>> Inserting Data INTO : silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info(
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT 
        cst_id ,
        cst_key,
        TRIM(UPPER(cst_firstname)) cst_firstname,
        TRIM(UPPER(cst_lastname)) cst_lastname,
        CASE
         WHEN cst_marital_status = 'M' THEN 'Married'
         WHEN cst_marital_status = 'F' THEN 'Single'
         ELSE 'N/A'
        END cst_marital_status,
        CASE 
         WHEN cst_gndr = 'F' THEN 'Female'
         WHEN cst_gndr = 'M' THEN 'Male'
         ELSE 'N/A'
        END cst_gndr,
        cst_create_date
    FROM 
    (
        SELECT *,
        ROW_NUMBER() OVER( PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_rank
        FROM bronze.crm_cust_info 
        WHERE cst_id IS NOT NULL
    )t 
    WHERE flag_rank = 1;
    SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '-----------------------------';

    SET @StartTime = GETDATE();
    PRINT '>> Truncating Table : silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info
    PRINT '>> Inserting Data INTO : silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info(
         prd_id,
         cat_id,
         prd_key,
         prd_nm,
         prd_cost,
         prd_line,
         prd_start_dt,
         prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
        prd_nm,
        ISNULL(prd_cost, 0) AS prd_cost,
        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(DATEADD(day, -1, 
             LEAD(prd_start_dt) OVER (
                    PARTITION BY SUBSTRING(prd_key, 7, LEN(prd_key)) ORDER BY prd_start_dt
                )
            ) AS DATE
        ) AS prd_end_dt
    FROM bronze.crm_prd_info;
    SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '-----------------------------';

    SET @StartTime = GETDATE();
    PRINT '>> Truncating Table : silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details
    PRINT '>> Inserting Data INTO : silver.crm_sales_details';
    INSERT INTO silver.crm_sales_details (
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
    SELECT 
	    sls_ord_num,
	    sls_prd_key,
	    sls_cust_id,
	    CASE 
		    WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		    ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	    END AS sls_order_dt,
	    CASE 
		    WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		    ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	    END AS sls_ship_dt,
	    CASE 
		    WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		    ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	    END AS sls_due_dt,
	    CASE 
		    WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
			    THEN sls_quantity * ABS(sls_price)
		    ELSE sls_sales
	    END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
	    sls_quantity,
	    CASE 
		    WHEN sls_price IS NULL OR sls_price <= 0 
			    THEN sls_sales / NULLIF(sls_quantity, 0)
		    ELSE sls_price  -- Derive price if original value is invalid
        END AS sls_price
	    FROM bronze.crm_sales_details;
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '-----------------------------';

    SET @StartTime = GETDATE();
    PRINT '>> Truncating Table : silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12
    PRINT '>> Inserting Data INTO : silver.erp_cust_az12';
    INSERT INTO silver.erp_cust_az12(
        cid,
        bdate,
        gen
    )

    SELECT 
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
             ELSE cid
        END cid,
        CASE WHEN bdate > GETDATE() THEN NULL
             ELSE bdate
        END bdate,
        CASE WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
             WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
             ELSE 'N/A'
        END gen
    FROM bronze.erp_cust_az12;
    SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '-----------------------------';

    SET @StartTime = GETDATE();
    PRINT '>> Truncating Table : silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101
    PRINT '>> Inserting Data INTO : silver.erp_loc_a101';
    INSERT INTO silver.erp_loc_a101
    (
        cid,
        cntry
    )
    SELECT 
        REPLACE(cid, '-','') cid,
        CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
             WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
             WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
             ELSE TRIM(cntry)
        END cntry
    FROM bronze.erp_loc_a101;
    SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '-----------------------------';


    SET @StartTime = GETDATE();
    PRINT '>> Truncating Table : silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2
    PRINT '>> Inserting Data INTO : silver.erp_px_cat_g1v2';
    INSERT INTO silver.erp_px_cat_g1v2
    (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT 
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;
    SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @StartTime, @EndTime) AS NVARCHAR)+ 'Seconds';
        PRINT '-----------------------------';
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
