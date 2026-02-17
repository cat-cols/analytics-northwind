-- ========================================
-- OPERATIONAL METRICS QUERIES
-- ========================================
-- Author: Brandon Hardison
-- Date: February 2026
-- Database: Northwind PostgreSQL
-- Purpose: Analyze shipping performance, order fulfillment, and operational efficiency
-- ========================================


-- ========================================
-- QUERY 22: Shipping Performance Analysis
-- ========================================
-- Business Question: How long does it take to ship orders by region?
-- Use Case: Identify bottlenecks, set realistic delivery expectations, improve logistics

-- Expected Output: Average shipping time by country
-- Expected Result: Some countries average 15+ days, others under 5 days

SELECT
    ship_country,
    COUNT(order_id) as total_orders,
    ROUND(AVG(shipped_date - order_date), 1) as avg_days_to_ship,
    ROUND(MIN(shipped_date - order_date), 1) as fastest_shipment,
    ROUND(MAX(shipped_date - order_date), 1) as slowest_shipment,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY shipped_date - order_date), 1) as median_days_to_ship
FROM orders
WHERE shipped_date IS NOT NULL
GROUP BY ship_country
HAVING COUNT(order_id) >= 5  -- Only countries with 5+ orders
ORDER BY avg_days_to_ship DESC;


-- ========================================
-- QUERY 23: Shipper Performance Comparison
-- ========================================
-- Business Question: Which shipping companies perform best?
-- Use Case: Negotiate better rates, choose reliable shippers, optimize shipping strategy

-- Expected Output: Performance metrics by shipping company
-- Expected Result: Compare 3 shippers on speed and cost
SELECT
    s.company_name as shipper,
    COUNT(DISTINCT o.order_id) as orders_shipped,
    ROUND(AVG(o.shipped_date - o.order_date), 1) as avg_days_to_ship,
    ROUND(SUM(o.freight)::numeric, 2) as total_freight_cost,
    ROUND(AVG(o.freight)::numeric, 2) as avg_freight_per_order,
    COUNT(CASE WHEN o.shipped_date - o.order_date <= 7 THEN 1 END) as orders_shipped_within_week,
    ROUND(100.0 * COUNT(CASE WHEN o.shipped_date - o.order_date <= 7 THEN 1 END) / 
          COUNT(*), 2) as on_time_percentage
FROM orders o
INNER JOIN shippers s ON o.ship_via = s.shipper_id
WHERE o.shipped_date IS NOT NULL
GROUP BY s.shipper_id, s.company_name
ORDER BY avg_days_to_ship ASC;


-- ========================================
-- QUERY 24: Late Orders Analysis
-- ========================================
-- Business Question: Which orders shipped late and why?
-- Use Case: Identify patterns in delays, improve customer communication

-- Expected Output: Orders that shipped after required date
-- Expected Result: ~20-30 orders shipped late, identify patterns
SELECT
    o.order_id,
    o.order_date,
    o.required_date,
    o.shipped_date,
    o.shipped_date - o.required_date as days_late,
    c.company_name as customer,
    c.country as customer_country,
    e.first_name || ' ' || e.last_name as employee_name,
    s.company_name as shipper,
    ROUND(o.freight::numeric, 2) as freight_cost
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN employees e ON o.employee_id = e.employee_id
INNER JOIN shippers s ON o.ship_via = s.shipper_id
WHERE o.shipped_date > o.required_date
ORDER BY days_late DESC
LIMIT 30;


-- ========================================
-- QUERY 25: Revenue Concentration (Pareto Analysis)
-- ========================================
-- Business Question: What percentage of revenue comes from top customers?
-- Use Case: Understand revenue risk, focus retention efforts on key accounts

-- Expected Output: Cumulative revenue distribution showing 80/20 rule
-- Expected Result: Top 20% of customers should generate ~80% of revenue
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.company_name,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_details od ON o.order_id = od.order_id
    GROUP BY c.customer_id, c.company_name
),
ranked_customers AS (
    SELECT
        customer_id,
        company_name,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) as cumulative_revenue,
        SUM(revenue) OVER () as total_revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) as customer_rank,
        COUNT(*) OVER () as total_customers
    FROM customer_revenue
)
SELECT
    customer_rank,
    company_name,
    revenue,
    ROUND(100.0 * revenue / total_revenue, 2) as percent_of_total_revenue,
    ROUND(100.0 * cumulative_revenue / total_revenue, 2) as cumulative_percent,
    ROUND(100.0 * customer_rank / total_customers, 2) as percentile_rank,
    CASE
        WHEN ROUND(100.0 * cumulative_revenue / total_revenue, 2) <= 80 THEN 'Top 80% Revenue'
        ELSE 'Bottom 20% Revenue'
    END as revenue_group
FROM ranked_customers
ORDER BY customer_rank
LIMIT 40;


-- ========================================
-- QUERY 26: Order Fulfillment Cycle Time
-- ========================================
-- Business Question: How long does our complete order-to-delivery cycle take?
-- Use Case: Process improvement, customer expectation setting

-- Expected Output: Breakdown of order processing stages
-- Expected Result: Shows typical 1-2 week fulfillment cycle
SELECT
    o.order_id,
    o.customer_id,
    c.country,
    o.order_date,
    o.required_date,
    o.shipped_date,
    o.shipped_date - o.order_date as order_to_ship_days,
    o.required_date - o.order_date as required_leadtime_days,
    CASE
        WHEN o.shipped_date IS NULL THEN 'Not Shipped'
        WHEN o.shipped_date <= o.required_date THEN 'On Time'
        WHEN o.shipped_date > o.required_date THEN 'Late'
    END as fulfillment_status,
    COUNT(od.product_id) as line_items,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as order_value
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_id, o.customer_id, c.country, o.order_date, o.required_date, o.shipped_date
ORDER BY o.order_date DESC
LIMIT 100;


-- ========================================
-- QUERY 27: SUMMARY of Key Business Metrics (Dashboard)
-- ========================================
-- Business Question: What are our overall business health metrics?
-- Use Case: Executive dashboard, monthly reporting

-- Expected Output: High-level KPIs in one view
-- Expected Result: Single row with all key business metrics
SELECT
    -- Customer Metrics
    (SELECT COUNT(DISTINCT customer_id) FROM customers) as total_customers,
    (SELECT COUNT(DISTINCT customer_id) FROM orders) as active_customers,

    -- Order Metrics
    (SELECT COUNT(*) FROM orders) as total_orders,
    (SELECT ROUND(AVG(shipped_date - order_date), 1)
     FROM orders WHERE shipped_date IS NOT NULL) as avg_shipping_days,

    -- Revenue Metrics
    (SELECT ROUND(SUM(unit_price * quantity * (1 - discount))::numeric, 2)
     FROM order_details) as total_revenue,
    (SELECT ROUND(AVG(order_total)::numeric, 2)
     FROM (SELECT SUM(unit_price * quantity * (1 - discount)) as order_total
           FROM order_details GROUP BY order_id) as order_totals) as avg_order_value,

    -- Product Metrics
    (SELECT COUNT(*) FROM products WHERE discontinued = 0) as active_products,
    (SELECT COUNT(DISTINCT category_id) FROM products) as product_categories,

    -- Employee Metrics
    (SELECT COUNT(*) FROM employees) as total_employees,

    -- Geographic Reach
    (SELECT COUNT(DISTINCT country) FROM customers) as countries_served;
