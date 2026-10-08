

 SELECT cst_id,
 COUNT(*)
 FROM bronze.crm_cust_info 
 GROUP BY cst_id
 HAVING COUNT(*) > 1

---------------------------------------------

SELECT *
FROM
(
SELECT *,
ROW_NUMBER() OVER( PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_rank
FROM bronze.crm_cust_info 
)t WHERE flag_rank != 1
----------------------------------------------------
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
--------------------------------------------------

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

--------------------------------------------------------
--CHECK WHETHER THERE ARE NULL OR DUPLICATES IN PRIMARY KEY

SELECT prd_id, COUNT(*) FROM bronze.crm_prd_info
GROUP BY prd_id 
HAVING COUNT(*) > 1

SELECT * FROM bronze.crm_prd_info
WHERE prd_id IS NULL

SELECT * FROM bronze.crm_prd_info
WHERE prd_cost IS NULL



-- CHECK FOR UNWANTED SPACES

SELECT prd_line FROM bronze.crm_prd_info
WHERE prd_line != TRIM(prd_line)

SELECT prd_nm FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- DATA CONSISTANCY AND STANDARDIZATION




SELECT * FROM bronze.crm_prd_info
SELECT * FROM bronze.erp_px_cat_g1v2

SELECT prd_id, COUNT(*) FROM bronze.crm_prd_info
GROUP BY prd_id 
HAVING COUNT(*) > 1

SELECT * FROM bronze.crm_prd_info
WHERE prd_id IS NULL

SELECT DISTINCT prd_line FROM bronze.crm_prd_info


SELECT prd_key,COUNT(prd_key) FROM bronze.crm_prd_info
GROUP BY prd_key

--CHECKING INVALID ORDERS
SELECT 
prd_key,
prd_start_dt,
LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN('AC-HE-HL-U509', 'AC-HE-HL-U509-R')



------------------------------------------------------------
--CHECK WHETHER THERE ARE NULL OR DUPLICATES IN PRIMARY KEY

SELECT sls_ord_num FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL
-- CHECK FOR UNWANTED SPACES
SELECT sls_prd_key FROM bronze.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)

SELECT sls_cust_id FROM bronze.crm_sales_details
WHERE  LEN(sls_cust_id) != 5


-- DATA CONSISTANCY AND STANDARDIZATION
SELECT NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR
sls_order_dt < 19500101 OR
sls_order_dt > 20300101 OR
LEN(sls_order_dt) !=8
--CHECKING INVALID ORDERS

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_due_dt OR sls_order_dt > sls_ship_dt

--  DATA CONSISTANCY
 SELECT sls_sales sls_old_sales,
       sls_quantity,
       sls_price sls_old_price,
       CASE
          WHEN sls_sales IS NULL OR sls_sales = 0
          THEN sls_quantity * ABS(sls_price)
          ELSE sls_sales
       END sls_sales,
       CASE WHEN sls_price IS NULL OR sls_price <= 0
         THEN sls_sales/ NULLIF(sls_quantity, 0)
         ELSE sls_price
       END sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR
sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL OR
sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0

--------------------------------------------------------------
-- DATA CONSISTANCY AND STANDARDIZATION

SELECT cid FROM bronze.erp_cust_az12
WHERE LEN(cid) != 10

SELECT DISTINCT gen FROM bronze.erp_cust_az12
--CHECKING INVALID DATES

select bdate from bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()


SELECT * FROM silver.erp_cust_az12
WHERE bdate > GETDATE()

--------------------------------------------------------------
SELECT 
cid
FROM bronze.erp_loc_a101 
WHERE cid not IN 
(SELECT cst_key FROM silver.crm_cust_info)

SELECT 
REPLACE(cid, '-','') cid
FROM bronze.erp_loc_a101 
WHERE cid  IN 
(SELECT cst_key FROM silver.crm_cust_info)




-- CHECK FOR UNWANTED SPACES
SELECT  cntry  FROM bronze.erp_loc_a101
WHERE DATALENGTH(cntry) != DATALENGTH(TRIM(cntry));


-- DATA CONSISTANCY AND STANDARDIZATION


SELECT DISTINCT cntry Old_cntry,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
     ELSE TRIM(cntry)
END cntry
FROM bronze.erp_loc_a101
ORDER BY cntry



-------------------------------------------------
SELECT * FROM bronze.erp_px_cat_g1v2

-- CHECK FOR UNWANTED SPACES
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat!= TRIM(cat) OR maintenance != (maintenance) OR subcat != TRIM(subcat)
