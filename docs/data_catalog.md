# Data Warehouse Catalog

## Gold Layer Overview

The Gold Layer contains business-ready, dimensional modeling tables optimized for analytics and reporting. These tables follow the star schema pattern with dimension tables (dim_*) and fact tables (fact_*) to support efficient querying and BI tool integration.

---

## Gold Layer Tables

### 1. gold.dim_customers

**Purpose:** Customer master dimension table containing cleaned and deduplicated customer attributes for analytical queries. This dimension provides a single source of truth for customer information across all fact tables.

**Source Tables:** 
- silver.crm_cust_info
- silver.erp_cust_az12
- silver.erp_loc_a101

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| customer_key | INT | Surrogate key for customer dimension | 1 |
| customer_id | INT | Natural key - unique customer identifier from source system | 11000 |
| customer_number | NVARCHAR(50) | Business-friendly customer code | AW00011000 |
| first_name | NVARCHAR(50) | Customer's first name | JON |
| last_name | NVARCHAR(50) | Customer's last name | YANG |
| full_name | NVARCHAR(101) | Concatenated full name for reporting | JON YANG |
| country | NVARCHAR(50) | Customer's country of residence | Australia |
| marital_status | NVARCHAR(50) | Customer's marital status (Married, Single, N/A) | Married |
| gender | NVARCHAR(50) | Customer's gender (Male, Female) | Male |
| birth_date | DATE | Customer's date of birth | 1971-10-06 |
| customer_create_date | DATE | Date customer record was created in source | 2025-10-06 |
| dwh_create_date | DATETIME2 | Data warehouse load timestamp | 2025-10-06 10:30:45.123 |
| is_active | INT | Flag indicating if customer is active (1=Yes, 0=No) | 1 |

---

### 2. gold.dim_products

**Purpose:** Product master dimension table providing detailed product information including categorization, line of business, and product lifecycle dates for accurate product-based analytics.

**Source Tables:**
- silver.crm_prd_info
- silver.erp_px_cat_g1v2

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| product_key | INT | Surrogate key for product dimension | 1 |
| product_id | INT | Natural key - unique product identifier from source | 210 |
| product_number | NVARCHAR(50) | Business-friendly product code | FR-R92R-58 |
| product_name | NVARCHAR(50) | Product display name | HL Road Frame - Red- 58 |
| category_id | NVARCHAR(50) | Product category code | CO_RF |
| category_name | NVARCHAR(50) | Product category name | Components |
| subcategory_name | NVARCHAR(50) | Product subcategory for further classification | Road Frames |
| product_line | NVARCHAR(50) | Product line assignment (Road, Mountain, etc.) | Road |
| product_cost | INT | Standard product cost | 0 |
| maintenance_required | NVARCHAR(50) | Flag indicating if product requires maintenance (Yes/No) | Yes |
| product_start_date | DATE | Product launch date | 2003-07-01 |
| product_end_date | DATE | Product discontinuation date (NULL if active) | NULL |
| dwh_create_date | DATETIME2 | Data warehouse load timestamp | 2025-10-06 10:30:45.123 |
| is_active | INT | Flag indicating if product is currently active (1=Yes, 0=No) | 1 |

---

### 3. gold.fact_sales

**Purpose:** Fact table containing transactional sales data at the order-line level, enabling revenue analysis, sales trends, and product performance metrics. Includes denormalized keys to support efficient joins with dimension tables.

**Source Tables:**
- silver.crm_sales_details

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| sales_key | INT | Surrogate key for sales fact (unique identifier) | 1001 |
| order_number | NVARCHAR(50) | Business order identifier | SO43697 |
| order_line_number | INT | Line number within order for multi-line orders | 1 |
| customer_key | INT | Foreign key linking to gold.dim_customers | 10769 |
| product_key | INT | Foreign key linking to gold.dim_products | 20 |
| order_date | DATE | Date order was placed | 2010-12-29 |
| shipping_date | DATE | Date order was shipped | 2011-01-05 |
| due_date | DATE | Expected delivery date | 2011-01-10 |
| sales_amount | INT | Total sales revenue for line item (quantity × price) | 3578 |
| order_quantity | INT | Quantity ordered | 1 |
| unit_price | INT | Unit price of product at time of sale | 3578 |
| dwh_create_date | DATETIME2 | Data warehouse load timestamp | 2025-10-06 10:30:45.123 |

---

## Data Quality & Lineage

- All gold layer tables are derived from and validated against silver layer source tables
- Surrogate keys are generated to ensure referential integrity and support slowly changing dimensions
- NULL values in date fields indicate currently active records (no end date)
- All timestamps use DATETIME2 for precision and are set at load time
- Regular reconciliation checks are performed between gold and silver layers
