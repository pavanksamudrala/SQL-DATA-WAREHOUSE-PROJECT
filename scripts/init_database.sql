-- Description:
-- This script initializes the SQL data warehouse by creating the DataWarehouse database
-- and the bronze, silver, and gold schemas used for layered data processing.
-- It is intended for local or development setup and should be run only in a controlled environment.

-- WARNING:
-- This script drops and recreates the DataWarehouse database if it already exists.
-- This is a destructive operation. Ensure that no critical data or active connections are using this database before running it.
-- Back up any required data and verify the target environment before executing this script.

USE master;

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
