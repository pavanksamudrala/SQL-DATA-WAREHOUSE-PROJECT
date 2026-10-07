SQL Server Data Warehouse & Analytics Project

An end-to-end Data Warehousing and Analytics solution built using Microsoft SQL Server and SQL Server Management Studio (SSMS).

📌 Project Attribution & Acknowledgment

This project was developed by following the hands-on tutorial video "SQL Full Course for Beginners / Zero to Hero" and project materials provided by Data with Baraa. Special thanks to Baraa Khatib Salkini for providing the project framework, ERP/CRM datasets, and architectural guidance.

🏗️ Data Architecture (Medallion Architecture)

The project follows a modern Medallion Architecture to extract, cleanse, transform, and model data across three progressive layers:

[ CRM Data (CSV) ]   \
                      ==> [ Bronze Layer ]  ==>  [ Silver Layer ]  ==>  [ Gold Layer ]
[ ERP Data (CSV) ]   /     (Raw Staging)          (Cleansed)          (Star Schema)


Bronze Layer: Stores raw ingested data as-is from source systems (ERP and CRM CSV files) into SQL Server.

Silver Layer: Handles data cleansing, normalization, deduplication, standardizing data types, and handling null values.

Gold Layer: Implements a dimensional Star Schema (Fact & Dimension tables) optimized for analytical queries, business reporting, and KPI calculations.

🛠️ Project Implementation Steps

1. Database Setup & Architecture Design

Installed and configured SQL Server Express and SQL Server Management Studio (SSMS).

Established consistent database naming conventions and isolated schemas (bronze, silver, gold).

2. Ingestion (Bronze Layer)

Created raw staging tables matching incoming CRM and ERP structures.

Loaded CSV datasets using T-SQL BULK INSERT scripts for high throughput.

3. Data Cleansing & Transformation (Silver Layer)

Transformed and standardized raw datasets:

Removed whitespace and uniform formatting using TRIM().

Standardized customer names, dates, and gender codes (M/F).

Handled missing attributes with default values (COALESCE/NULL handling).

Calculated surrogate key mappings and resolved cross-system key discrepancies.

4. Data Modeling (Gold Layer)

Designed a Star Schema modeling customer, product, and sales entities:

gold.dim_customers: Master customer demographics combined from CRM and ERP.

gold.dim_products: Product catalog hierarchy, categories, and maintenance costs.

gold.fact_sales: Transactional sales data linked via surrogate keys.

5. Analytics & Business Intelligence

Developed SQL scripts for exploratory data analysis (EDA):

Customer segmentation and lifetime value (LTV).

Product performance and revenue breakdown.

Time-series sales trend analysis (YoY, MoM).

📊 Sample Data & Queries

Sample Star Schema Definition (Gold Layer)

-- Gold Layer: Customer Dimension
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    ci.cst_id                          AS customer_id,
    ci.cst_key                         AS customer_number,
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END                                AS gender,
    ca.bdate                           AS birth_date,
    ci.cst_create_date                 AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid;


Sample Business Analytics Query

-- Monthly Sales Trend & KPI Summary
SELECT 
    YEAR(order_date)  AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_revenue,
    SUM(quantity)     AS total_units_sold
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year DESC, order_month DESC;


📁 Repository Structure

├── datasets/             # Raw CRM and ERP CSV source files
├── docs/                 # Architecture & Data Flow Diagrams (.drawio)
├── scripts/
│   ├── bronze/           # DDL & Bulk Insert scripts for raw data
│   ├── silver/           # Cleansing, Transformation & Procedure scripts
│   ├── gold/             # Dimension & Fact view creation scripts
│   └── analytics/        # Business Intelligence and KPI queries
├── LICENSE               # MIT License file
└── README.md             # Project documentation


🛡️ License

This project is open-source and available under the MIT License. You are free to use, modify, and distribute this repository with appropriate attribution.
