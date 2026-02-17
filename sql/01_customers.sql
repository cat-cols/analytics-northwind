-- ========================================
-- CUSTOMER ANALYSIS QUERIES
-- ========================================
-- Author: Brandon Hardison
-- Date: February 2026
-- Database: Northwind PostgreSQL
-- Purpose: Analyze customer behavior, segmentation, lifetime value, and retention

-- Style: snake_case, Explicit INNER JOINs
-- Disable pager and set aligned format for better readability
\pset pager off
\pset format aligned
\pset columns 200
\set ON_ERROR_STOP on
-- ========================================



-- ========================================
-- QUERY 1: Top 10 Customers by Revenue
-- ========================================
-- Business Question: Who are our most valuable customers?
-- Use Case: Identify VIP customers for retention programs

-- Expected Output: Customer name, country, order count, total revenue
-- Expected Result: QUICK-Stop from Germany should be #1 with ~$110K
SELECT
    c.customer_id,
    c.company_name,
    c.country,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(od.unit_price::numeric * od.quantity::numeric * (1::numeric - od.discount::numeric)),2) AS total_revenue
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name, c.country
ORDER BY total_revenue DESC
LIMIT 10;

-- ========================================
-- QUERY 2: Customer Retention Analysis
-- ========================================
-- Business Question: What percentage of customers are repeat buyers?
-- Use Case: Measure customer loyalty and retention effectiveness

-- repeat_rate = customers with more than 1 order
-- retention_proxy = customers who bought again within X days or in a later year/quarter

-- Expected Output: One-time vs repeat customer breakdown with percentages
-- Expected Result: ~76% repeat customer rate

WITH customer_order_counts AS (
  SELECT customer_id, COUNT(DISTINCT order_id) AS order_count
  FROM orders
  GROUP BY customer_id
),
customer_first AS (
  SELECT customer_id, MIN(order_date) AS first_order_date
  FROM orders
  GROUP BY customer_id
),
repeat_within_90 AS (
  SELECT o.customer_id
  FROM orders o
  JOIN customer_first f USING (customer_id)
  WHERE o.order_date > f.first_order_date
    AND o.order_date <= f.first_order_date + INTERVAL '90 days'
  GROUP BY o.customer_id
)
SELECT
  COUNT(*) AS total_customers,
  COUNT(*) FILTER (WHERE coc.order_count = 1) AS one_time_customers,
  COUNT(*) FILTER (WHERE coc.order_count > 1) AS repeat_customers,
  ROUND(
    100 * COUNT(*) FILTER (WHERE coc.order_count > 1)::numeric / NULLIF(COUNT(*)::numeric, 0),
    2
  ) AS repeat_customer_pct,
  COUNT(r.customer_id) AS repeat_within_90d_customers,
  ROUND(
    100 * COUNT(r.customer_id)::numeric / NULLIF(COUNT(*)::numeric, 0),
    2
  ) AS repeat_within_90d_pct
FROM customer_order_counts coc
LEFT JOIN repeat_within_90 r USING (customer_id);

-- ========================================
-- QUERY 3: Customer Lifetime Value (CLV)
-- ========================================
-- Business Question: What is the lifetime value of each customer?
-- Use Case: Prioritize high-value customers, inform marketing spend

-- Expected Output: Customer ID, first/last order dates, total orders, CLV, avg order value
-- Expected Result: Top customers should have $50K-$110K lifetime value

SELECT
    c.customer_id,
    c.company_name,
    c.country,
    MIN(o.order_date) as first_order_date,
    MAX(o.order_date) as last_order_date,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as lifetime_value,
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as avg_order_line_net_revenue,
    ROUND(COUNT(*)::numeric / NULLIF(COUNT(DISTINCT o.order_id)::numeric, 0), 2) AS avg_lines_per_order
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name, c.country
ORDER BY lifetime_value DESC
LIMIT 2;

-- ========================================
-- QUERY 4: Customer Lifetime Value (CLV) - Alternative
-- Alternative CLV calculation using order totals CTE
-- ========================================
WITH order_totals AS (
  SELECT
    o.customer_id,
    o.order_id,
    o.order_date,
    SUM(
      od.unit_price::numeric
      * od.quantity::numeric
      * (1::numeric - od.discount::numeric)
    ) AS order_total
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  GROUP BY o.customer_id, o.order_id, o.order_date
)
SELECT
  c.customer_id,
  c.company_name,
  c.country,
  MIN(ot.order_date) AS first_order_date,
  MAX(ot.order_date) AS last_order_date,
  COUNT(DISTINCT ot.order_id) AS total_orders,
  ROUND(SUM(ot.order_total), 2) AS lifetime_value,
  ROUND(AVG(ot.order_total), 2) AS avg_order_value,
  ROUND(COUNT(*)::numeric / NULLIF(COUNT(DISTINCT ot.order_id)::numeric, 0), 2) AS avg_lines_per_order
FROM customers c
JOIN order_totals ot ON c.customer_id = ot.customer_id
GROUP BY c.customer_id, c.company_name, c.country
ORDER BY lifetime_value DESC
LIMIT 2;

-- ========================================
-- QUERY 5: Customer Segmentation (RFM-style)
-- ========================================
-- Business Question: How can we segment customers by value and behavior?
-- Use Case: Targeted marketing campaigns, personalized service levels

-- Expected Output: Customer segments with counts and average metrics
-- Expected Result: VIP (5-10 customers), High Value (~20), Regular (~30), Occasional (~30)

WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.company_name,
        COUNT(DISTINCT o.order_id) as order_count,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as total_spent,
        MAX(o.order_date) as last_order_date,
        CURRENT_DATE - MAX(o.order_date) as days_since_last_order
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_details od ON o.order_id = od.order_id
    GROUP BY c.customer_id, c.company_name
)
SELECT
    CASE
        WHEN total_spent > 25000 AND order_count > 15 THEN 'VIP'
        WHEN total_spent > 10000 OR order_count > 10 THEN 'High Value'
        WHEN total_spent > 5000 OR order_count > 5 THEN 'Regular'
        ELSE 'Occasional'
    END as customer_segment,
    COUNT(*) as customer_count,
    ROUND(AVG(total_spent), 2) as avg_spent,
    ROUND(AVG(order_count), 2) as avg_orders,
    ROUND(AVG(days_since_last_order), 0) as avg_days_since_purchase
FROM customer_metrics
GROUP BY customer_segment
ORDER BY avg_spent DESC;


-- ========================================
-- QUERY 6: Customer Geographic Distribution
-- ========================================
-- Business Question: Where are our customers located and how do regions perform?
-- Use Case: Geographic expansion planning, regional marketing strategies

-- Expected Output: Country breakdown with customer count, orders, revenue
-- Expected Result: Germany, USA, Brazil should be top 3 countries

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) as customer_count,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as total_revenue,
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as avg_order_line_value,
    ROUND((SUM(od.unit_price * od.quantity * (1 - od.discount)) / COUNT(DISTINCT c.customer_id))::numeric, 2) as revenue_per_customer
    -- same as before, but with explicit cast
    -- ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)) / COUNT(DISTINCT c.customer_id), 2) as revenue_per_customer
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.country
HAVING COUNT(DISTINCT c.customer_id) >= 3  -- Only countries with 3+ customers
ORDER BY total_revenue DESC;
