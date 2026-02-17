-- ========================================
-- PRODUCT ANALYSIS QUERIES
-- ========================================
-- Author: Brandon Hardison
-- Date: February 2026
-- Database: Northwind PostgreSQL
-- Purpose: Analyze product performance, inventory, pricing, and category trends

-- Revenue definition: gross line revenue net of line-item discount.
    -- Excludes shipping/freight, tax/VAT, returns, refunds, and currency effects.
    -- Assumes unit_price is the transaction price captured on the order line.

-- Data Assumptions:
-- 1) order_details.unit_price is the transaction price at time of sale.
-- 2) discount is a rate in [0,1].
-- 3) quantities are non-negative integers.
-- 4) discontinued=0 indicates currently active products.
-- 5) avg_price = average transaction unit price on order lines (not the product list price).

-- Time window: all available history in Northwind (no date filter applied).
-- To analyze recent performance, filter on orders.order_date.
-- Optional: WHERE o.order_date >= DATE '1997-01-01'
-- ========================================

-- Disable pager and set aligned format for better readability
\pset pager off
\pset format aligned
\pset columns 200

-- ========================================
-- QUERY 11: Top Products by Revenue
-- ========================================
-- Business Question: Which products generate the most revenue?
-- Use Case: Identify star products, optimize inventory, inform marketing

-- avg_price = average transaction unit price on order lines (not product list price)

-- Expected Output: Product name, category, units sold, revenue, avg price
-- Expected Result: Top product should be around $40K-$50K revenue

SELECT
    p.product_name,
    c.category_name,
    SUM(od.quantity)
        AS units_sold,
    ROUND(
  SUM(
    od.unit_price::numeric
    * od.quantity::numeric
    * (1::numeric - od.discount::numeric)
    ),
    2
    ) AS total_revenue,
    ROUND(AVG(od.unit_price)::numeric, 2)
        AS avg_price,
    ROUND((SUM(od.unit_price::numeric * od.quantity::numeric) / NULLIF(SUM(od.quantity)::numeric, 0)), 2)
        AS weighted_avg_unit_price,
    COUNT(DISTINCT od.order_id)
        AS times_ordered
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
INNER JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_revenue DESC
LIMIT 15;

-- ========================================
-- QUERY 12: Category Performance Analysis
-- ========================================
-- Business Question: Which product categories perform best?
-- Use Case: Category-level investment decisions, marketing budget allocation

-- Explicit cast to numeric to avoid type mismatch warnings

-- Expected Output: Category breakdown with product count, units sold, revenue
-- Expected Result: Beverages and Dairy typically lead in revenue
SELECT
    c.category_name,
    c.description,
    COUNT(DISTINCT p.product_id) as product_count,
    SUM(od.quantity) as total_units_sold,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as category_revenue,
    ROUND(AVG(od.unit_price)::numeric, 2) as avg_product_price,
    ROUND((SUM(od.unit_price::numeric * od.quantity::numeric * (1::numeric - od.discount::numeric))
        / NULLIF(SUM(od.quantity)::numeric, 0)), 2) AS revenue_per_unit
FROM categories c
INNER JOIN products p ON c.category_id = p.category_id
INNER JOIN order_details od ON p.product_id = od.product_id
GROUP BY c.category_id, c.category_name, c.description
ORDER BY category_revenue DESC;


-- ========================================
-- QUERY 13: Slow-Moving Inventory Analysis
-- ========================================
-- Business Question: Which products are selling slowly or not at all?
-- Use Case: Identify products to discount, discontinue, or promote

-- Inventory status thresholds are heuristic for demo purposes.
-- In production, thresholds should be parameterized by category/seasonality/lead time.

-- Expected Output: Products with low sales, stock levels, inventory status
-- Expected Result: Should identify 10-15 slow-moving products
-- Note: HAVING clause restricts output to products with <100 units sold (focus list).

SELECT
    p.product_name,
    c.category_name,
    p.units_in_stock,
    p.units_on_order,
    COALESCE(SUM(od.quantity), 0) as total_units_sold,
    COALESCE(COUNT(DISTINCT od.order_id), 0) as times_ordered,
    ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount)), 0)::numeric, 2) as total_revenue,
    CASE
        WHEN SUM(od.quantity) IS NULL THEN 'Never Sold'
        WHEN SUM(od.quantity) < 50 THEN 'Slow Moving'
        WHEN SUM(od.quantity) < 200 THEN 'Moderate'
        ELSE 'Fast Moving'
    END as inventory_status
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name, c.category_name, p.units_in_stock, p.units_on_order
HAVING COALESCE(SUM(od.quantity), 0) < 100  -- Products with less than 100 units sold
ORDER BY total_units_sold ASC, p.units_in_stock DESC;

-- ========================================
-- QUERY 14: Product Pricing Analysis
-- ========================================
-- Business Question: How do product prices compare within categories?
-- Use Case: Pricing strategy, identify premium vs budget products

-- Expected Output: Products with price comparison to category average
-- Expected Result: Mix of premium, standard, and budget products per category

WITH product_category_stats AS (
    SELECT
        c.category_id,
        c.category_name,
        p.product_id,
        p.product_name,
        p.unit_price,
        AVG(p.unit_price) OVER (PARTITION BY c.category_id) as avg_category_price,
        MIN(p.unit_price) OVER (PARTITION BY c.category_id) as min_category_price,
        MAX(p.unit_price) OVER (PARTITION BY c.category_id) as max_category_price
    FROM products p
    INNER JOIN categories c ON p.category_id = c.category_id
    WHERE p.discontinued = 0
)
SELECT
    category_name,
    product_name,
    ROUND(unit_price::numeric, 2) as product_price,
    ROUND(avg_category_price::numeric, 2) as category_avg_price,
    ROUND(((unit_price - avg_category_price) / avg_category_price * 100)::numeric, 2) as price_vs_avg_percent,
    CASE
        WHEN unit_price > avg_category_price * 1.3 THEN 'Premium'
        WHEN unit_price < avg_category_price * 0.7 THEN 'Budget'
        ELSE 'Standard'
    END as price_tier
FROM product_category_stats
ORDER BY category_name, unit_price DESC;

-- ========================================
-- QUERY 15: Product Bundling Opportunities
-- ========================================
-- Business Question: Which products are frequently bought together?
-- Use Case: Create product bundles, cross-selling recommendations

-- "Bought together" = products appearing on the same order_id (one co-occurrence per order line pair)
-- Does not account for customer repeats, timing proximity, or lift/confidence metrics

-- set the cutoff at the 10th percentile of pair co-occurrence
-- used LIMIT 20 because max co-occurrence was 7 in this dataset

-- Expected Output: Product pairs frequently purchased in same order
-- Expected Result: Common pairings like related beverages or complementary foods

-- Improvements:
-- - COUNT(DISTINCT od1.order_id) as orders_bought_together
-- - ROUND(AVG(od1.quantity)::numeric, 1) as avg_qty_product_1,

SELECT
    p1.product_name as product_1,
    p2.product_name as product_2,
    COUNT(DISTINCT od1.order_id) as orders_bought_together,
    ROUND(AVG(od1.quantity)::numeric, 1) as avg_qty_product_1,
    ROUND(AVG(od2.quantity)::numeric, 1) as avg_qty_product_2
FROM order_details od1
INNER JOIN order_details od2
    ON od1.order_id = od2.order_id
    AND od1.product_id < od2.product_id  -- Avoid duplicate pairs
INNER JOIN products p1 ON od1.product_id = p1.product_id
INNER JOIN products p2 ON od2.product_id = p2.product_id
GROUP BY p1.product_id, p1.product_name, p2.product_id, p2.product_name
HAVING COUNT(DISTINCT od1.order_id) >= 5  -- Only pairs bought together (x)+ times
ORDER BY orders_bought_together DESC
LIMIT 20;
