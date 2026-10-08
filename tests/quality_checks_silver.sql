-- =========================================================
-- DATA QUALITY CHECKS FOR BRONZE TO SILVER TRANSFORMATION
-- =========================================================
-- This file contains simple validation queries to detect dirty,
-- duplicate, missing, inconsistent, and malformed data before
-- building the silver layer.
-- =========================================================


-- =========================================================
-- CRM DATA QUALITY CHECKS
-- =========================================================

-- 1. CUSTOMER DATA QUALITY
-- Check for duplicate customer IDs in CRM customer table
SELECT cst_id,
       COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Check duplicate customer records and keep only the latest record
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS rn
    FROM bronze.crm_cust_info
) t
WHERE rn != 1;

-- Check for unwanted spaces in customer last name
SELECT cst_id,
       cst_firstname,
       cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


-- 2. PRODUCT DATA QUALITY
-- Check duplicate product IDs in CRM product table
SELECT prd_id,
       COUNT(*) AS duplicate_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- Check null product IDs
SELECT *
FROM bronze.crm_prd_info
WHERE prd_id IS NULL;

-- Check null product cost
SELECT *
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL;

-- Check unwanted spaces in product fields
SELECT prd_id,
       prd_line,
       prd_nm
FROM bronze.crm_prd_info
WHERE prd_line != TRIM(prd_line)
   OR prd_nm != TRIM(prd_nm);

-- Review distinct product lines
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

-- Check how many records exist for each product key
SELECT prd_key,
       COUNT(*) AS record_count
FROM bronze.crm_prd_info
GROUP BY prd_key;

-- Check for invalid product date ranges or sequence gaps
SELECT prd_key,
       prd_start_dt,
       LEAD(prd_start_dt) OVER (
           PARTITION BY prd_key
           ORDER BY prd_start_dt
       ) - 1 AS expected_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509', 'AC-HE-HL-U509-R');


-- 3. SALES DATA QUALITY
-- Check null order numbers
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL;

-- Check unwanted spaces and invalid customer ID length
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)
   OR LEN(sls_cust_id) != 5;

-- Check invalid order date values
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR sls_order_dt < 19500101
   OR sls_order_dt > 20300101
   OR LEN(CAST(sls_order_dt AS VARCHAR)) != 8;

-- Check invalid order logic (order date after due date or ship date)
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_due_dt
   OR sls_order_dt > sls_ship_dt;

-- Check sales and price consistency
SELECT sls_sales AS old_sales,
       sls_quantity,
       sls_price AS old_price,
       CASE
           WHEN sls_sales IS NULL OR sls_sales = 0
           THEN sls_quantity * ABS(sls_price)
           ELSE sls_sales
       END AS corrected_sales,
       CASE
           WHEN sls_price IS NULL OR sls_price <= 0
           THEN sls_sales / NULLIF(sls_quantity, 0)
           ELSE sls_price
       END AS corrected_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0;


-- =========================================================
-- ERP DATA QUALITY CHECKS
-- =========================================================

-- 4. ERP CUSTOMER MASTER
-- Check invalid customer ID length
SELECT cid
FROM bronze.erp_cust_az12
WHERE LEN(cid) != 10;

-- Review distinct gender values
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

-- Check invalid birth dates
SELECT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();

-- Check if silver customer data contains dates beyond today
SELECT *
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();


-- 5. ERP LOCATION MASTER
-- Check if location customer IDs are missing in CRM customer table
SELECT cid
FROM bronze.erp_loc_a101
WHERE cid NOT IN (
    SELECT cst_key
    FROM silver.crm_cust_info
);

-- Check if customer IDs exist but have formatting differences
SELECT REPLACE(cid, '-', '') AS cid
FROM bronze.erp_loc_a101
WHERE cid IN (
    SELECT cst_key
    FROM silver.crm_cust_info
);

-- Check unwanted spaces in country names
SELECT cntry
FROM bronze.erp_loc_a101
WHERE DATALENGTH(cntry) != DATALENGTH(TRIM(cntry));

-- Standardize country values
SELECT DISTINCT cntry AS old_cntry,
       CASE
           WHEN TRIM(cntry) = 'DE' THEN 'Germany'
           WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
           WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
           ELSE TRIM(cntry)
       END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;


-- 6. ERP PRODUCT CATEGORY MASTER
-- Check for unwanted spaces in category fields
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR maintenance != TRIM(maintenance)
   OR subcat != TRIM(subcat);

-- =========================================================
-- END OF DATA QUALITY CHECKS
-- =========================================================
