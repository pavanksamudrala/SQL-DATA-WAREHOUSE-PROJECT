# SQL Server Data Warehouse & Analytics Project

An end-to-end data warehousing and analytics solution built using Microsoft SQL Server and SQL Server Management Studio (SSMS).

## Overview

This project demonstrates how to design and implement a modern data warehouse using the Medallion Architecture model. It covers raw data ingestion, cleansing and transformation, dimensional modeling, and business analytics using SQL-based workflows.

The solution integrates data from multiple source systems, transforms it into trusted analytical tables, and exposes it through a star schema optimized for reporting and KPI analysis.

---

## Project Attribution & Acknowledgment

This project was developed by following the hands-on tutorial video, "SQL Full Course for Beginners / Zero to Hero", and project materials provided by Data with Baraa. Special thanks to Baraa Khatib Salim for the educational guidance and practical learning approach.

---

## Data Architecture

### Medallion Architecture

The project follows a three-layer architecture designed to progressively refine raw data into analytics-ready datasets:

```text
[ CRM Data (CSV) ]     ┐
                       ├──> [ Bronze Layer ] ──> [ Silver Layer ] ──> [ Gold Layer ]
[ ERP Data (CSV) ]     ┘
                         (Raw staging)         (Cleansed)          (Star schema)
```

### Layer Breakdown

#### Bronze Layer
Stores raw ingested data as-is from source systems (ERP and CRM CSV files) into SQL Server.

#### Silver Layer
Handles data cleansing, normalization, deduplication, standardization of data types, and null value handling.

#### Gold Layer
Implements a dimensional star schema with fact and dimension tables optimized for analytical queries, reporting, and KPI calculations.

---

## Project Implementation Steps

### 1. Database Setup & Architecture Design

- Installed and configured SQL Server Express and SQL Server Management Studio (SSMS)
- Established consistent database naming conventions
- Isolated schemas for `bronze`, `silver`, and `gold`

### 2. Ingestion (Bronze Layer)

- Created raw staging tables matching the incoming CRM and ERP source structures
- Loaded CSV datasets using T-SQL `BULK INSERT` scripts for high-throughput ingestion

### 3. Data Cleansing & Transformation (Silver Layer)

The raw data was standardized and cleaned using SQL-based transformations, including:

- Removing unnecessary whitespace and formatting issues with `TRIM()`
- Standardizing customer names, dates, and gender codes (`M/F`)
- Handling missing values with `COALESCE()` and default replacements
- Resolving cross-system key mismatches and surrogate key mapping

### 4. Data Modeling (Gold Layer)

Designed a star schema for key business entities:

- `gold.dim_customers`: customer demographics consolidated from CRM and ERP data
- `gold.dim_products`: product hierarchy, categories, and maintenance costs
- `gold.fact_sales`: transactional sales records linked through surrogate keys

### 5. Analytics & Business Intelligence

Built SQL scripts for exploratory data analysis and reporting, including:

- Customer segmentation and lifetime value (LTV)
- Product performance and revenue analysis
- Time-series sales trend analysis such as YoY and MoM comparisons

---

## Sample Data & Queries

### Gold Layer Example: Customer Dimension View

```sql
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
```

### Example Business Analytics Query

```sql
-- Monthly Sales Trend & KPI Summary
SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_revenue,
    SUM(quantity) AS total_units_sold
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year DESC, order_month DESC;
```

---

## Repository Structure

```text
├── datasets/             # Raw CRM and ERP CSV source files
├── docs/                 # Architecture and data flow diagrams (.drawio)
├── scripts/
│   ├── bronze/           # DDL and bulk insert scripts for raw data
│   ├── silver/           # Cleansing, transformation, and procedure scripts
│   ├── gold/             # Dimension and fact view creation scripts
│   └── analytics/        # Business intelligence and KPI queries
├── LICENSE               # MIT License file
├── README.md             # Project documentation
└── .gitignore            # Git ignore rules
```

---

## License

This project is open-source and available under the MIT License. You are free to use, modify, and distribute the repository with appropriate attribution.
