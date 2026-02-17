-- ========================================
-- EMPLOYEE PERFORMANCE QUERIES
-- ========================================
-- Author: Brandon Hardison
-- Date: February 2026
-- Database: Northwind PostgreSQL
-- Purpose: Analyze employee sales performance, efficiency, and territory coverage
-- ========================================


-- ========================================
-- QUERY 16: Employee Sales Performance
-- ========================================
-- Business Question: Which employees generate the most sales?
-- Use Case: Performance reviews, commission calculations, sales targets
-- Expected Output: Employee name, title, orders processed, revenue generated
-- Expected Result: Top performer should have $200K+ in sales
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    e.title,
    e.city as employee_location,
    COUNT(DISTINCT o.order_id) as orders_processed,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as total_sales,
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as avg_order_line_value,
    COUNT(DISTINCT o.customer_id) as unique_customers_served
FROM employees e
INNER JOIN orders o ON e.employee_id = o.employee_id
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.title, e.city
ORDER BY total_sales DESC;


-- ========================================
-- QUERY 17: Employee Efficiency Metrics
-- ========================================
-- Business Question: How efficient are our sales representatives?
-- Use Case: Identify training needs, benchmark performance, optimize workload

-- Expected Output: Efficiency metrics including orders per month, revenue per order
-- Expected Result: ~30-40 orders per month per employee average
WITH employee_metrics AS (
    SELECT
        e.employee_id,
        e.first_name || ' ' || e.last_name as employee_name,
        COUNT(DISTINCT o.order_id) as total_orders,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as total_revenue,
        MIN(o.order_date) as first_order,
        MAX(o.order_date) as last_order,
        MAX(o.order_date) - MIN(o.order_date) as days_active
    FROM employees e
    INNER JOIN orders o ON e.employee_id = o.employee_id
    INNER JOIN order_details od ON o.order_id = od.order_id
    GROUP BY e.employee_id, e.first_name, e.last_name
)
SELECT
    employee_name,
    total_orders,
    total_revenue,
    ROUND(total_revenue / total_orders, 2) as revenue_per_order,
    days_active,
    ROUND(total_orders::numeric / NULLIF((days_active / 30.0), 0), 2) as orders_per_month,
    ROUND(total_revenue::numeric / NULLIF((days_active / 30.0), 0), 2) as revenue_per_month
FROM employee_metrics
WHERE days_active > 0
ORDER BY total_revenue DESC;


-- ========================================
-- QUERY 18: Employee Territory Performance
-- ========================================
-- Business Question: How do employees perform across different regions?
-- Use Case: Territory assignment optimization, regional sales strategies

-- Expected Output: Employee performance broken down by customer country
-- Expected Result: Shows which employees are strong in which territories

SELECT
    e.first_name || ' ' || e.last_name as employee_name,
    c.country as customer_country,
    COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue,
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as avg_line_value
FROM employees e
INNER JOIN orders o ON e.employee_id = o.employee_id
INNER JOIN order_details od ON o.order_id = od.order_id
INNER JOIN customers c ON o.customer_id = c.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name, c.country
HAVING COUNT(DISTINCT o.order_id) >= 5  -- Only territories with 5+ orders
ORDER BY employee_name, revenue DESC;


-- ========================================
-- QUERY 19: Employee Year-Over-Year Growth
-- ========================================
-- Business Question: How is each employee's performance trending?
-- Use Case: Identify high performers vs those needing support

-- Expected Output: YoY comparison of employee sales
-- Expected Result: Shows growth trends for each employee
WITH yearly_employee_sales AS (
    SELECT
        e.employee_id,
        e.first_name || ' ' || e.last_name as employee_name,
        EXTRACT(YEAR FROM o.order_date) as year,
        COUNT(DISTINCT o.order_id) as orders,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
    FROM employees e
    INNER JOIN orders o ON e.employee_id = o.employee_id
    INNER JOIN order_details od ON o.order_id = od.order_id
    GROUP BY e.employee_id, e.first_name, e.last_name, EXTRACT(YEAR FROM o.order_date)
)
SELECT
    employee_name,
    year,
    orders as current_year_orders,
    revenue as current_year_revenue,
    LAG(revenue) OVER (PARTITION BY employee_name ORDER BY year) as previous_year_revenue,
    ROUND(revenue - LAG(revenue) OVER (PARTITION BY employee_name ORDER BY year), 2) as revenue_change,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (PARTITION BY employee_name ORDER BY year)) / 
          NULLIF(LAG(revenue) OVER (PARTITION BY employee_name ORDER BY year), 0), 2) as yoy_growth_percent
FROM yearly_employee_sales
ORDER BY employee_name, year;


-- ========================================
-- QUERY 20: Top Performing Employee-Product Combinations
-- ========================================
-- Business Question: Which employees excel at selling which products?
-- Use Case: Product training focus, leverage employee strengths

-- Expected Output: Employee-product pairs with highest sales
-- Expected Result: Identifies which employees are best at selling specific products

SELECT
    e.first_name || ' ' || e.last_name as employee_name,
    p.product_name,
    c.category_name,
    SUM(od.quantity) as units_sold,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
FROM employees e
INNER JOIN orders o ON e.employee_id = o.employee_id
INNER JOIN order_details od ON o.order_id = od.order_id
INNER JOIN products p ON od.product_id = p.product_id
INNER JOIN categories c ON p.category_id = c.category_id
GROUP BY e.employee_id, e.first_name, e.last_name, p.product_id, p.product_name, c.category_name
HAVING SUM(od.quantity) >= 50  -- Only products where employee sold 50+ units
ORDER BY revenue DESC
LIMIT 30;
