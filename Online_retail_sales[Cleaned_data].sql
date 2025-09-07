
-- .....PROJECT : RETAIL SALES AND CUSTOMER ANALYTICS.....

-- ==========================================
-- TABLE 1: [customer_summary copy] 
-- ==========================================

-- 1. View the table structure and sample data
SELECT TOP 20 * 
FROM [customer_summary copy];

EXEC sp_help 'customer_summary copy';

SELECT DISTINCT COUNT(*) 
FROM [customer_summary copy];

-------------------------------------------------
-- 2. Check for NULLs or placeholder values
-------------------------------------------------
SELECT *
FROM [customer_summary copy]
WHERE CustomerID IS NULL
   OR LTRIM(RTRIM(CustomerID)) IN ('NA', 'N/A', 'NULL', '') 
   OR total_orders IS NULL
   OR total_quantity IS NULL
   OR total_spent IS NULL
   OR last_purchase IS NULL
   OR first_purchase IS NULL;

-------------------------------------------------
-- 3. Check for invalid numeric values
-------------------------------------------------
SELECT *
FROM [customer_summary copy]
WHERE total_orders <= 0
   OR total_quantity < 0
   OR total_spent < 0;

-------------------------------------------------
-- 4. Remove rows with invalid CustomerIDs
-------------------------------------------------
DELETE FROM [customer_summary copy]
WHERE LTRIM(RTRIM(CustomerID)) IN ('NA', 'N/A', 'NULL', '');

-------------------------------------------------
-- 5. Fix data types
-------------------------------------------------
ALTER TABLE [customer_summary copy]
ALTER COLUMN total_orders INT;

-------------------------------------------------
-- 6. Standardize numeric columns
-------------------------------------------------
UPDATE [customer_summary copy]
SET total_spent = ROUND(total_spent, 2);

-------------------------------------------------
-- 7. Check for duplicates
-------------------------------------------------
;WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY last_purchase DESC) AS rn
    FROM [customer_summary copy]
)
SELECT *
FROM CTE
WHERE rn > 1;

-------------------------------------------------
-- 8. Split datetime into date and time
-------------------------------------------------
ALTER TABLE [customer_summary copy]
ADD first_purchase_date DATE,
    first_purchase_time TIME,
    last_purchase_date DATE,
    last_purchase_time TIME;

UPDATE [customer_summary copy]
SET first_purchase_date = CAST(first_purchase AS DATE),
    first_purchase_time = CAST(first_purchase AS TIME),
    last_purchase_date  = CAST(last_purchase  AS DATE),
    last_purchase_time  = CAST(last_purchase  AS TIME);

-- Drop original datetime columns
ALTER TABLE [customer_summary copy]
DROP COLUMN first_purchase,
            last_purchase;

-- Convert TIME columns to clean HH:MM:SS format
ALTER TABLE [customer_summary copy]
ALTER COLUMN first_purchase_time VARCHAR(8);

ALTER TABLE [customer_summary copy]
ALTER COLUMN last_purchase_time VARCHAR(8);

-------------------------------------------------
-- 9. Final Cleaned Selection (optional check)
-------------------------------------------------
SELECT 
    CAST(CustomerID AS INT) AS CustomerID,
    CAST(total_orders AS INT) AS total_orders,
    total_quantity,
    ROUND(total_spent, 2) AS total_spent,
    first_purchase_date,
    first_purchase_time,
    last_purchase_date,
    last_purchase_time
FROM [customer_summary copy]
WHERE total_orders > 0
  AND total_quantity >= 0
  AND total_spent >= 0;

-------------------------------------------------
-- 10. Create a new cleaned table
-------------------------------------------------
SELECT
    CAST(CustomerID AS INT) AS CustomerID,          
    total_orders,                                    
    total_quantity,                                  
    ROUND(total_spent, 2) AS total_spent,           
    first_purchase_date,                             
    first_purchase_time,                             
    last_purchase_date,                             
    last_purchase_time                               
INTO cleaned_customer_summary
FROM [customer_summary copy];
-------------------------------------------------------------

-- ==========================================
--  TABLE:2  [monthly_sales copy]
-- ==========================================
select * from [monthly_sales copy];
select distinct count(*) from [monthly_sales copy];
-- 1. Check table structure
EXEC sp_help '[monthly_sales copy]'; 

-- 2. Remove duplicate rows (keep highest revenue if duplicates exist)
;WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY InvoiceMonth ORDER BY monthly_revenue DESC) AS rn
    FROM [monthly_sales copy]
)
DELETE FROM CTE WHERE rn > 1;

-- 3. Remove rows with NULL / invalid placeholders
DELETE FROM [monthly_sales copy]
WHERE InvoiceMonth IS NULL
   OR LTRIM(RTRIM(InvoiceMonth)) IN ('NA', 'N/A', 'NULL', '')
   OR monthly_revenue IS NULL
   OR LTRIM(RTRIM(monthly_revenue)) IN ('NA', 'N/A', 'NULL', '');

-- 4. Remove rows with zero or negative revenue
DELETE FROM [monthly_sales copy]
WHERE monthly_revenue <= 0;

-- 5. Standardize dates to first day of month (keep type as DATE)
UPDATE [monthly_sales copy]
SET InvoiceMonth = DATEFROMPARTS(YEAR(InvoiceMonth), MONTH(InvoiceMonth), 1);

-- 6. Convert monthly_revenue to INT (rounding)
UPDATE [monthly_sales copy]
SET monthly_revenue = ROUND(monthly_revenue, 0);

ALTER TABLE [monthly_sales copy]
ALTER COLUMN monthly_revenue INT;

UPDATE [monthly_sales copy]
SET InvoiceMonth = FORMAT(InvoiceMonth, 'dd-MM-yyyy');


-- ==========================================
-- FINAL SELECT: display InvoiceMonth in DD-MM-YYYY format
-- ==========================================
SELECT FORMAT(InvoiceMonth, 'dd-MM-yyyy') AS InvoiceMonth,
       monthly_revenue
FROM [monthly_sales copy];

SELECT  InvoiceMonth, monthly_revenue                                      
INTO cleaned_monthly_sales                               
FROM [monthly_sales copy];

--------------------------------------------------------------
-- =========================================================
--  TABLE 3: Retail_cleaned
-- =========================================================

-- STEP 1: View Table Structure & Sample Data

EXEC sp_help 'retail_cleaned';

SELECT TOP 20 * 
FROM retail_cleaned;

-- STEP 2: Remove Duplicate Records , Based on InvoiceNo + StockCode

;WITH CTE AS
(
    SELECT *,
           ROW_NUMBER() OVER (
                PARTITION BY InvoiceNo, StockCode
                ORDER BY InvoiceDate
           ) AS RowNum
    FROM retail_cleaned
)
DELETE FROM CTE
WHERE RowNum > 1;

-- STEP 3: Add New Columns for Cleaned Date & Time

ALTER TABLE retail_cleaned
ADD Invoice_Date DATE,
    Invoice_Time TIME(0);

-- STEP 4: Convert Invoice_Date & Invoice_Time from VARCHAR to DATE & TIME

-- Ensure Invoice_Date and Invoice_Time are in correct format
ALTER TABLE retail_cleaned 
ALTER COLUMN Invoice_Date VARCHAR(10);

ALTER TABLE retail_cleaned 
ALTER COLUMN Invoice_Time VARCHAR(8);

-- Convert Invoice_Date from VARCHAR to DATE
UPDATE retail_cleaned
SET Invoice_Date = TRY_CONVERT(DATE, Invoice_Date, 105); 

-- Convert Invoice_Time from VARCHAR to TIME
UPDATE retail_cleaned
SET Invoice_Time = TRY_CONVERT(TIME(0), Invoice_Time, 108);  

-- Alter columns back to proper data types
ALTER TABLE retail_cleaned
ALTER COLUMN Invoice_Date DATE;

ALTER TABLE retail_cleaned
ALTER COLUMN Invoice_Time TIME(0);

-- STEP 5: Drop Original InvoiceDate Column 

ALTER TABLE retail_cleaned
DROP COLUMN InvoiceDate;

-- STEP 6: Ensure InvoiceMonth is Proper DATE Format

ALTER TABLE retail_cleaned
ALTER COLUMN InvoiceMonth DATE;

UPDATE retail_cleaned
SET InvoiceMonth = CONVERT(DATE, InvoiceMonth, 105);

-- STEP 6B: Convert Quantity, UnitPrice & TotalPrice to proper data types

ALTER TABLE retail_cleaned
ALTER COLUMN Quantity INT;

ALTER TABLE retail_cleaned
ALTER COLUMN UnitPrice DECIMAL(10,2);

ALTER TABLE retail_cleaned
ALTER COLUMN TotalPrice DECIMAL(10,2);

-- STEP 7: Validate Invoice_Date Against InvoiceMonth

SELECT 
    InvoiceNo,
    Invoice_Date,
    InvoiceMonth
FROM retail_cleaned
WHERE Invoice_Date = InvoiceMonth;

-- STEP 8: Create Cleaned Retail_cleaned Table

SELECT *
INTO cleaned_retail_final
FROM retail_cleaned;

-- ==================================================
--      TABLE: 4 Retail_Segmented
-- ==================================================

-- STEP 1: View Table Structure & Sample Data

SELECT * 
FROM retail_segmented;

EXEC sp_help 'retail_segmented';

SELECT COUNT(*) 
FROM retail_segmented;

-- STEP 2: Remove Duplicate Records , Based on InvoiceNo + StockCode

;WITH CTE AS
(
    SELECT *,
           ROW_NUMBER() OVER (
                PARTITION BY InvoiceNo, StockCode
                ORDER BY InvoiceDate
           ) AS RowNum
    FROM retail_segmented
)
DELETE FROM CTE
WHERE RowNum > 1;

-- STEP 3: Convert UnitPrice & TotalPrice to DECIMAL

ALTER TABLE retail_segmented
ALTER COLUMN UnitPrice DECIMAL(10,2);

ALTER TABLE retail_segmented
ALTER COLUMN TotalPrice DECIMAL(10,2);

-- STEP 4: Add New Columns for Cleaned Date & Time

ALTER TABLE retail_segmented
ADD Invoice_Date DATE,
    Invoice_Time TIME(0);

-- Convert TIME & DATE columns to VARCHAR temporarily 
ALTER TABLE retail_cleaned 
ALTER COLUMN Invoice_Time VARCHAR(8);

ALTER TABLE retail_cleaned
ALTER COLUMN Invoice_Date VARCHAR(10);

-- STEP 5: Populate New Date & Time Columns from InvoiceDate

UPDATE retail_segmented
SET Invoice_Date = CAST(InvoiceDate AS DATE),
    Invoice_Time = CAST(InvoiceDate AS TIME(0));

-- STEP 6: Drop Original InvoiceDate Column 

ALTER TABLE retail_segmented
DROP COLUMN InvoiceDate;

-- STEP 7: Convert Other Columns to Proper Data Types

-- Convert InvoiceNo from VARCHAR → INT
ALTER TABLE retail_segmented
ALTER COLUMN InvoiceNo INT;

-- Convert Quantity to INT
ALTER TABLE retail_segmented
ALTER COLUMN Quantity INT;

-- Convert CustomerID to INT
ALTER TABLE retail_segmented
ALTER COLUMN CustomerID INT;

-- =========================================================
-- STEP 8: Create Cleaned Retail_segmented Table
-- =========================================================
SELECT *
INTO cleaned_retail_segment
FROM retail_segmented;

