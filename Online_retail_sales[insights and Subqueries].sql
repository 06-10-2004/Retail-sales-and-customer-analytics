
-- .....PROJECT : RETAIL SALES AND CUSTOMER ANALYTICS.....

select * from cleaned_customer_summary;
select * from cleaned_monthly_sales;
select * from cleaned_retail_final;
select * from cleaned_retail_segment;
------------------------------------------
-- Overall context

-- 1. total customers
select count(distinct CustomerID) as Total_customers
from cleaned_customer_summary;

-- 2. total orders/ transactions
select count(distinct InvoiceNo) as Total_orders
from cleaned_retail_final

-- 3. total revenue
select sum(TotalPrice) as Total_revenue
from cleaned_retail_final

-- 4. Total Products
select count(distinct StockCode) as total_products
from cleaned_retail_final;

-- 5. New vs Returning customer
select
    case when total_orders = 1 then 'New Customer' else 'Returning Customer' end as customer_type,
    count(*) as customer_count
from cleaned_customer_summary
group by case when total_orders = 1 then 'New Customer' else 'Returning Customer' end;

--6. Average order per customer
select avg(total_orders) as avg_order_per_customer
from cleaned_customer_summary;

--7. Average revenue per customer
select round(sum(total_spent)/ count(distinct CustomerID), 0) as avg_revenue_per_customer
from cleaned_customer_summary;

--8. Number of customers per segment
select s.Segment, count(distinct c.CustomerID) as num_customers
from cleaned_customer_summary as c
join cleaned_retail_segment as s
on c.CustomerID = s.CustomerID
group by s.Segment
order by num_customers;

--9. Top selling products
select top 10 stockcode, description, sum(TotalPrice) as total_revenue
from cleaned_retail_final
group by stockcode, description
order by total_revenue desc;

--10. Low-performing products
select top 10 stockcode, description, sum(totalprice) as total_revenue
from cleaned_retail_final
group by stockcode, description
order by total_revenue asc;

--11. Revenue contribution by category
select stockcode, description,
       sum(totalprice) AS product_revenue,
       cast(sum(totalprice) * 100.0 / (select sum(totalprice) from cleaned_retail_final) as decimal(10,2)) as revenue_pct
from cleaned_retail_final
group by stockcode, description
order by revenue_pct desc;

-- Time - Based Overview

--1. Monthly orders
select format(invoice_date,'yyyy-MM') as month, count(distinct invoiceno) as total_orders
from cleaned_retail_final
group by format(invoice_date,'yyyy-MM')
order by month;

--2. Monthly revenue
select format(invoice_date,'yyyy-MM') AS month, round(cast(sum(totalprice) as decimal(10,2)),0) total_revenue
from cleaned_retail_final
group by format(invoice_date,'yyyy-MM')
order by month;

--3. Weekly orders
select datepart(year, invoice_date) as year, 
datepart(week, invoice_date) as week,
count(distinct invoiceno) as total_orders
from cleaned_retail_final
group by datepart(year, invoice_date), datepart(week, invoice_date)
order by year, week;

--4. Weekly revenue
select datepart(year, invoice_date) as year,
      datepart(week, invoice_date) as week,
      round(sum(totalprice),0) as total_revenue
from cleaned_retail_final
group by datepart(year, invoice_date), datepart(week, invoice_date)
order by year, week;

-- Customer Activity Metrics

--1. Percentage of active customers
select cast(count(distinct case when total_orders > 0 then customerid end) * 100.0/
   count(distinct customerid) as decimal(10,2)) as pct_active_customers
from cleaned_customer_summary;

--2. Customers with no purchase in the last 6 months
declare @current_date date = '2011-12-31';

select cast(sum(case when datediff(month, last_purchase_date, @current_date) >= 6 then 1 else 0 end) * 100.0 /
            count(*) as decimal(10,2)) AS churn_rate_pct
FROM cleaned_customer_summary;

--3. Average time between purchases
with purchase_dates as (
   select CustomerID, Invoice_Date,
   row_number() over(partition by customerid order by invoice_date) as rn
   from cleaned_retail_final
)
select avg(datediff(day, prev.Invoice_Date, curr.Invoice_Date)) as avg_days_between_purchases
from purchase_dates as curr
join purchase_dates prev
on curr.CustomerID = prev.CustomerID
and curr.rn = prev.rn+1;

-- Funnel Analysis

--1. Customers who placed at least one order
Select count(distinct CustomerID) as total_customers,
sum(case when total_orders>0 then 1 else 0 end) as active_customers
from cleaned_customer_summary;

--2. Conversion rate (first purchase -> repeat purchase)
Select cast(sum(case when total_orders > 1 then 1 else 0 end)* 100.0 / 
count(*) as decimal(10,2)) as conversion_rate
from cleaned_customer_summary;

-- Retention Analysis

--1. Monthly retention rate
with first_purchase as(
select CustomerID, min(InvoiceMonth) as first_month
from cleaned_retail_final
group by CustomerID
)
select 
r.InvoiceMonth,
count(distinct case when r.InvoiceMonth = f.first_month then r.CustomerID end) as new_customers,
count(distinct r.CustomerID) as retained_customers,
cast(count(distinct r.CustomerID)* 100.0/
nullif(count(distinct case when r.invoicemonth = f.first_month then r.customerid end),0)
as decimal(10,2)) as retention_rate
from cleaned_retail_final as r
join first_purchase as f
on r.CustomerID = f.CustomerID
group by InvoiceMonth
order by InvoiceMonth;

--2. Average time between first and second purchase
with purchase_dates as(
   select CustomerID, Invoice_Date,
   row_number() over(partition by customerid order by invoice_date) as rn
   from cleaned_retail_final
  )
  select avg(datediff(day, first.Invoice_Date, next.Invoice_Date)) [avg days to second purchase]
  from purchase_dates as first
  join purchase_dates as next
  on first.CustomerID = next.CustomerID
  and first.rn = 1
  and next.rn = 2;

--3. Segment wise retention
select s.Segment,
   count(distinct case when c.total_orders > 1 then c.CustomerID end) as retained_customers,
   count(distinct c.customerid) as total_customers,
   cast(count(distinct case when c.total_orders > 1 then c.CustomerID end)* 100.0/
         count(distinct c.customerid) as decimal(10,2)) as retention_rate
from cleaned_customer_summary as c
join cleaned_retail_segment as s
on c.CustomerID = s.CustomerID
group by s.Segment
order by retention_rate desc;

-- Churn Rate

--1. Customers inactive in last 3, 6, 12 months
Declare @current_date date = '2011-12-31';

select 
    sum(case when DATEDIFF(MONTH,last_purchase_date, @current_date) >= 3 then 1 else 0 end) as churned_3_months,
	sum(case when DATEDIFF(MONTH,last_purchase_date, @current_date) >= 6 then 1 else 0 end) as churned_6_months,
	sum(case when DATEDIFF(MONTH,last_purchase_date, @current_date) >= 12 then 1 else 0 end) as churned_12_months
from cleaned_customer_summary;

--2. Monthly churn rate
WITH active_customers AS (
    SELECT InvoiceMonth, COUNT(DISTINCT customerid) AS active_count
    FROM cleaned_retail_final
    GROUP BY InvoiceMonth
),
prev_active AS (
    SELECT InvoiceMonth, LAG(active_count) OVER (ORDER BY InvoiceMonth) AS prev_count, active_count
    FROM active_customers
)
SELECT InvoiceMonth,
       CASE WHEN prev_count IS NULL THEN 0
            ELSE CAST((prev_count - active_count) * 100.0 / prev_count AS DECIMAL(10,2)) END AS churn_rate
FROM prev_active
ORDER BY InvoiceMonth;

--3. High-value customers at risk of churn
SELECT TOP 20 customerid, total_spent, last_purchase_date
FROM cleaned_customer_summary
WHERE DATEDIFF(MONTH, last_purchase_date, GETDATE()) >= 6
ORDER BY total_spent DESC;

-- Engagement Metrics

--1. Total quantity purchased per customer per month
select CustomerID, InvoiceMonth, sum(Quantity) as total_quantity
from cleaned_retail_final
group by CustomerID, InvoiceMonth
order by CustomerID, InvoiceMonth;

--2. Average spend per order
select cast(sum(TotalPrice)*1.0/count(distinct InvoiceMonth) as decimal(10,2)) as avg_spend_per_ordeer
from cleaned_retail_final;

--3. Time-of-day & day-of-week shopping activity
SELECT DATENAME(WEEKDAY, invoice_date) AS day_of_week,
       DATEPART(HOUR, invoice_time) AS hour_of_day,
       COUNT(*) AS total_orders
FROM cleaned_retail_final
GROUP BY DATENAME(WEEKDAY, invoice_date), DATEPART(HOUR, invoice_time)
ORDER BY total_orders DESC;

-- Actitvation Rate

--1. Percentage of new customers purchasing within X days
DECLARE @days INT = 7;
select cast(sum(case when datediff(day, first_purchase_date, last_purchase_date) <= @days then 1 else 0 end) * 100.0/
count(*) as decimal(10,2)) as activation_rate
from cleaned_customer_summary;

--2. Time to first purchase
SELECT AVG(DATEDIFF(DAY, first_purchase_date, last_purchase_date)) AS avg_days_to_first_purchase
FROM cleaned_customer_summary;

--3. Activation rate by segment
select s.Segment, 
cast(sum(case when c.total_orders > 0 then 1 else 0 end) * 100.0/
count(distinct c.CustomerID) as decimal(10,2)) as activation_rate
from cleaned_customer_summary as c
join cleaned_retail_segment as s
on c.CustomerID = s.CustomerID
group by s.Segment;

-- Referral and Loyalty Metrics

--1. Repeat customers
select count(*) AS repeat_customers
from cleaned_customer_summary
where total_orders > 1;

--2. Loyalty contribution to revenue
select s.segment,
       round(sum(c.total_spent), 2) as segment_revenue,
       cast(sum(c.total_spent) * 100.0 / 
            (select sum(total_spent) from cleaned_customer_summary) as decimal(10,2)) as revenue_share
from cleaned_customer_summary c
JOIN cleaned_retail_segment s 
     on c.CustomerID = s.CustomerID
group by s.segment
order by segment_revenue desc;

-- Revenue Metrics

--1. Monthly revenue trends
select InvoiceMonth, sum(monthly_revenue) as total_revenue
from cleaned_monthly_sales
group by InvoiceMonth
order by InvoiceMonth;

--2. Revenue by customer segement
select s.Segment, sum(r.TotalPrice) as total_revenue
from cleaned_retail_final as r
join cleaned_retail_segment as s
on cast(r.InvoiceNo as varchar) = cast(s.InvoiceNo as varchar)
group by s.Segment
order by total_revenue desc;

--3. Customer Lifetime Value [LTV]
select customerid, total_spent as lifetime_value
from cleaned_customer_summary
order by lifetime_value desc;


