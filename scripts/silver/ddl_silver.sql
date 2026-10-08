-- Silver layer table definitions for CRM and ERP data
-- Purpose: These tables store cleaned and standardized business data from source systems.
-- Key point: Each table includes a dwh_create_date timestamp to track when the record was loaded into the warehouse.

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
   DROP TABLE silver.crm_cust_info;

-- Table: silver.crm_cust_info
-- Description: Customer master data from the CRM source system.
-- Key point: cst_id and cst_key are the main identifiers used to track customer records.
CREATE TABLE silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
   DROP TABLE silver.crm_prd_info;

-- Table: silver.crm_prd_info
-- Description: Product master data from the CRM product catalog.
-- Key point: prd_id and prd_key are used to join product records across downstream models.
CREATE TABLE silver.crm_prd_info (
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
   DROP TABLE silver.crm_sales_details;

-- Table: silver.crm_sales_details
-- Description: Sales transaction details capturing orders, products, and customer relationships.
-- Key point: sls_ord_num, sls_prd_key, and sls_cust_id together identify each sales event and enable fact-to-dimension joins.
CREATE TABLE silver.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
   DROP TABLE silver.erp_loc_a101;

-- Table: silver.erp_loc_a101
-- Description: ERP location data containing country information.
-- Key point: cid and cntry represent the location identifier and the geographic attribute used for reporting.
CREATE TABLE silver.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
   DROP TABLE silver.erp_cust_az12;

-- Table: silver.erp_cust_az12
-- Description: ERP customer profile information with personal and demographic attributes.
-- Key point: cid links this table to customer records across ERP data sources.
CREATE TABLE silver.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
   DROP TABLE silver.erp_px_cat_g1v2;

-- Table: silver.erp_px_cat_g1v2
-- Description: ERP product category hierarchy and maintenance metadata.
-- Key point: id, cat, and subcat define the classification structure used to map product categories.
CREATE TABLE silver.erp_px_cat_g1v2 (
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
