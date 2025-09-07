# Retail-sales-and-customer-analytics
"Analyzing retail sales and customer behavior to optimize revenue, retention, and marketing strategies using SQL Server."
---
##  1. Background and Overview

As a Data Analyst, this project focuses on using SQL Server to transform raw retail sales data into actionable insights.
By analyzing customer behavior, sales trends, product performance, and retention patterns, the project helps businesses make informed decisions.

**Key Notes:**
> Excel was only used to import the raw datasets into SQL Server.
> All data cleaning, transformation, aggregation, and analysis were performed using T-SQL queries.
> Insights generated can help optimize marketing, inventory, retention strategies, and revenue growth.

**Business Context & Goals:**
- Clean and transform raw retail datasets into structured, analyzable tables.
- Identify high-value customers and product performance patterns.
- Understand seasonal and temporal trends in sales and revenue.
- Provide recommendations for targeted marketing and retention strategies.

**Why this project matters:**  
- Retail datasets are often inconsistent and require extensive cleaning.
- Insights can guide promotions, inventory, and customer engagement campaigns.
- Helps reduce churn, increase customer lifetime value (LTV), and maximize revenue.

---

##  2. Data Structure Overview

**Main Tables Used:**

1. **`customer_summary`**
   - Columns: `CustomerID`, `total_orders`, `total_quantity`, `total_spent`, `first_purchase_date`, `last_purchase_date`, etc.
   - Cleansing Steps: Removed nulls/invalid values, standardized numeric and date fields, removed duplicates, split datetime into date and time.
   - Key Metrics: Customer retention, churn, LTV, repeat purchase rate.

2. **`monthly_sales`**
   - Columns: `InvoiceMonth`, `monthly_revenue`
   - Cleansing Steps: Removed duplicates, fixed invalid/null data, standardized dates to first day of month, converted revenue to INT.

3. **`retail_cleaned`**
   - Columns: `InvoiceNo`, `StockCode`, `Quantity`, `UnitPrice`, `TotalPrice`, `Invoice_Date`, `Invoice_Time`, `InvoiceMonth`
   - Cleansing Steps: Removed duplicates, converted data types, extracted date/time from datetime, ensured proper revenue calculations.

4. **`retail_segmented`**
   - Columns: `InvoiceNo`, `CustomerID`, `StockCode`, `Quantity`, `UnitPrice`, `TotalPrice`, `Invoice_Date`, `Invoice_Time`
   - Cleansing Steps: Removed duplicates, converted columns to proper types, created cleaned table `cleaned_retail_segment`.

---

##  3. Executive Summary

**Key Insights:**

- **Customer Loyalty:** 66% of customers are returning, showing strong retention.
- **Revenue Concentration:** Top 10 products contribute ~2% each; many products generate negligible sales.
- **High-Value Segments:** Segment 4 contains 3,055 customers, contributing significant revenue.
- **Seasonal Trends:** Peak sales occur in November, with notable drops in December 2011.
- **Engagement Patterns:** Peak shopping occurs midday, especially on Tuesday and Wednesday.
- **Churn & Activation:** ~22% churn over 6 months; only ~37% of new customers purchase within 7 days.

---

##  4. Insights Deep Dive

**Insight 1: Customer Retention**
- **Quantified Value:** 65.58% repeat purchase rate
- **Metric:** Retention
- **Story:** Two-thirds of customers make multiple purchases, with high loyalty in segments 2 & 3.

**Insight 2: Revenue Concentration**
- **Quantified Value:** Top 10 products drive up to 2% each of revenue
- **Metric:** Revenue Concentration
- **Story:** Few products generate majority of revenue; low-performing products should be re-evaluated.

**Insight 3: Seasonal Trends**
- **Quantified Value:** November 2011 → ₹1.49M revenue
- **Metric:** Monthly Revenue
- **Story:** Marketing and inventory should focus on weeks 45–50 for maximum impact.

**Insight 4: High-Value Customers at Risk**
- **Quantified Value:** Top 20 customers with ≥₹250k spent, inactive ≥6 months
- **Metric:** Churn Risk
- **Story:** Target retention campaigns to retain high-value customers.

**Insight 5: Activation Gap**
- **Quantified Value:** Average 130 days to first purchase; 36.54% purchase within 7 days
- **Metric:** Customer Activation
- **Story:** Faster onboarding needed to convert new customers earlier.

---

##  5. Recommendations

- Introduce **loyalty programs** for high-value segments (Segment 2 & 3).  
- **Promote top-selling products** during peak months (October–November).  
- **Target at-risk high-value customers** with personalized campaigns.  
- Reduce **churn in Segment 1** through engagement and incentives.  
- Improve **new customer activation** by streamlining onboarding within the first 7 days.

---

##  6. Caveats and Assumptions

- Churn calculation assumes no purchase in last 6 months.  
- Average time to second purchase seems unusually low (1 day); verify dataset and multiple same-day transactions.  
- ROI and revenue insights do not account for cost data.  
- Some negative monthly churn rates indicate more new customers than lost customers in that period.  
- Segmentation and revenue attribution assume accurate mapping of customers to segments.

---

##  7. Tools:
     1. SQL Server – Primary platform used for data cleaning, transformation, aggregation, and analysis using T-SQL queries.
     2. T-SQL – Advanced querying language used to calculate metrics like retention, churn, revenue trends, and customer segmentation.
     3. Excel – Only used to import raw datasets into SQL Server; no analysis or transformation was performed in Excel.

## 8. Conclusion:
      This project provides a comprehensive view of retail sales and customer behavior, demonstrating how SQL Server can be used to clean, prepare, and analyze raw data to generate actionable business insights.
      By examining customer behavior, product performance, revenue trends, and retention patterns, businesses
      Overall, this analysis highlights the importance of structured SQL workflows and thorough data cleaning, 
      turning raw retail datasets into insights that support strategic business decisions and long-term growth.
