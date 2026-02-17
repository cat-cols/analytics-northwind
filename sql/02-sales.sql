-- ========================================
-- SALES TREND ANALYSIS QUERIES
-- ========================================
-- Author: Brandon Hardison
-- Date: February 2026
-- Database: Northwind PostgreSQL
-- Purpose: Analyze sales patterns over time, seasonal trends, growth metrics
-- ========================================

-- ========================================
-- QUERY 6: Monthly Sales Trend
-- ========================================
-- Business Question: What are our month-by-month sales trends?
-- Use Case: Identify sales patterns, forecast future revenue, plan inventory
-- Expected Output: Monthly breakdown with order count, revenue, avg order value

SELECT
    TO_CHAR(o.order_date, 'YYYY-MM') as month,
    COUNT(DISTINCT o.order_id) as order_count,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as monthly_revenue,
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as avg_line_value,
    COUNT(DISTINCT o.customer_id) as unique_customers
FROM orders o
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY month;

-- Expected Result: Should show ~24 months of data (1996-1998)


-- ========================================
-- QUERY 7: Year-Over-Year Growth
-- ========================================
-- Business Question: How is revenue growing year-over-year?
-- Use Case: Measure business growth, inform strategic planning
-- Expected Output: Yearly comparison with growth percentages

WITH yearly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_date) as year,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
    FROM orders o
    INNER JOIN order_details od ON o.order_id = od.order_id
    GROUP BY EXTRACT(YEAR FROM o.order_date)
)
SELECT 
    year,
    revenue as current_year_revenue,
    LAG(revenue) OVER (ORDER BY year) as previous_year_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY year), 2) as revenue_change,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY year)) / 
          NULLIF(LAG(revenue) OVER (ORDER BY year), 0), 2) as yoy_growth_percent
FROM yearly_revenue
ORDER BY year;

-- Expected Result: 1997 should show strong growth vs 1996


-- ========================================
-- QUERY 8: Quarterly Performance
-- ========================================
-- Business Question: Are there seasonal patterns in our sales?
-- Use Case: Seasonal staffing, inventory planning, marketing timing
-- Expected Output: Quarter breakdown with revenue and order counts

SELECT 
    EXTRACT(YEAR FROM o.order_date) as year,
    EXTRACT(QUARTER FROM o.order_date) as quarter,
    'Q' || EXTRACT(QUARTER FROM o.order_date) || ' ' || EXTRACT(YEAR FROM o.order_date) as period,
    COUNT(DISTINCT o.order_id) as order_count,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue,
    COUNT(DISTINCT o.customer_id) as active_customers
FROM orders o
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY 
    EXTRACT(YEAR FROM o.order_date),
    EXTRACT(QUARTER FROM o.order_date)
ORDER BY year, quarter;

-- Expected Result: Q4 typically shows higher sales (holiday season)


-- ========================================
-- QUERY 9: Day of Week Analysis
-- ========================================
-- Business Question: Which days of the week generate the most orders?
-- Use Case: Staffing optimization, promotion timing
-- Expected Output: Day breakdown with order counts and revenue

SELECT 
    TO_CHAR(o.order_date, 'Day') as day_of_week,
    EXTRACT(DOW FROM o.order_date) as day_number,  -- 0=Sunday, 6=Saturday
    COUNT(DISTINCT o.order_id) as order_count,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue,
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as avg_line_value
FROM orders o
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY 
    TO_CHAR(o.order_date, 'Day'),
    EXTRACT(DOW FROM o.order_date)
ORDER BY day_number;

-- Expected Result: Weekdays should show more business activity than weekends


-- ========================================
-- QUERY 10: Average Order Frequency
-- ========================================
-- Business Question: How frequently do customers place orders?
-- Use Case: Customer engagement metrics, retention strategies
-- Expected Output: Average days between orders per customer

WITH customer_orders AS (
    SELECT
        customer_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) as previous_order_date
    FROM orders
)
SELECT
    ROUND(AVG(order_date - previous_order_date), 1) as avg_days_between_orders,
    ROUND(MIN(order_date - previous_order_date), 1) as min_days_between_orders,
    ROUND(MAX(order_date - previous_order_date), 1) as max_days_between_orders,
    -- PERCENTILE_CONT returns double precision but ROUND() in PostgreSQL needs numeric type => cast to numeric with ::numeric
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY order_date - previous_order_date)::numeric, 1) as median_days_between_orders
    -- ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY order_date - previous_order_date), 1) as median_days_between_orders
FROM customer_orders
WHERE previous_order_date IS NOT NULL;

-- Expected Result: ~40-50 days average between customer orders