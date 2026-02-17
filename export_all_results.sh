#!/bin/bash

# ===========================================
# Master Export Script - SQL Business Intelligence Project
# ===========================================
# Purpose: Export all key query results to CSV files
# Author: Your Name
# Date: February 2024
# Usage: ./scripts/export_all_results.sh
# ===========================================

# Project directory
PROJECT_DIR="/Users/b/data/projects/sql-business-intelligence"
cd "$PROJECT_DIR"

# Create results subdirectories if they don't exist
mkdir -p results/{customer_analysis,sales_trends,product_analysis,employee_performance,operational_metrics}

echo "=================================="
echo "SQL Analysis Results Export"
echo "=================================="
echo ""

# ========================================
# CUSTOMER ANALYSIS EXPORTS
# ========================================
echo "📊 Exporting Customer Analysis..."

# Top 10 Customers
psql -U postgres -d northwind -c "
SELECT c.customer_id, c.company_name, c.country,
       COUNT(DISTINCT o.order_id) as total_orders,
       ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as total_revenue
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name, c.country
ORDER BY total_revenue DESC LIMIT 10;
" --csv > results/customer_analysis/top_10_customers.csv

# Customer Retention
psql -U postgres -d northwind -c "
WITH customer_order_counts AS (
    SELECT customer_id, COUNT(DISTINCT order_id) as order_count
    FROM orders GROUP BY customer_id
)
SELECT 
    COUNT(CASE WHEN order_count = 1 THEN 1 END) as one_time_customers,
    COUNT(CASE WHEN order_count > 1 THEN 1 END) as repeat_customers,
    COUNT(*) as total_customers,
    ROUND(100.0 * COUNT(CASE WHEN order_count > 1 THEN 1 END) / COUNT(*), 2) as repeat_percentage
FROM customer_order_counts;
" --csv > results/customer_analysis/customer_retention.csv

# Customer Segments
psql -U postgres -d northwind -c "
WITH customer_metrics AS (
    SELECT c.customer_id, c.company_name,
           COUNT(DISTINCT o.order_id) as order_count,
           ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as total_spent
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
    END as segment,
    COUNT(*) as customers,
    ROUND(AVG(total_spent), 2) as avg_spent
FROM customer_metrics
GROUP BY segment ORDER BY avg_spent DESC;
" --csv > results/customer_analysis/customer_segments.csv

echo "   ✅ Customer analysis exported (3 files)"

# ========================================
# SALES TRENDS EXPORTS
# ========================================
echo "📈 Exporting Sales Trends..."

# Monthly Sales
psql -U postgres -d northwind -c "
SELECT TO_CHAR(o.order_date, 'YYYY-MM') as month,
       COUNT(DISTINCT o.order_id) as order_count,
       ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
FROM orders o
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY month;
" --csv > results/sales_trends/monthly_sales.csv

# YoY Growth
psql -U postgres -d northwind -c "
WITH yearly_revenue AS (
    SELECT EXTRACT(YEAR FROM o.order_date) as year,
           ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
    FROM orders o
    INNER JOIN order_details od ON o.order_id = od.order_id
    GROUP BY EXTRACT(YEAR FROM o.order_date)
)
SELECT year, revenue,
       LAG(revenue) OVER (ORDER BY year) as prev_year,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY year)) / 
             NULLIF(LAG(revenue) OVER (ORDER BY year), 0), 2) as yoy_growth_pct
FROM yearly_revenue ORDER BY year;
" --csv > results/sales_trends/yoy_growth.csv

echo "   ✅ Sales trends exported (2 files)"

# ========================================
# PRODUCT ANALYSIS EXPORTS
# ========================================
echo "📦 Exporting Product Analysis..."

# Top Products
psql -U postgres -d northwind -c "
SELECT p.product_name, c.category_name,
       SUM(od.quantity) as units_sold,
       ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
INNER JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY revenue DESC LIMIT 15;
" --csv > results/product_analysis/top_products.csv

# Category Performance
psql -U postgres -d northwind -c "
SELECT c.category_name,
       COUNT(DISTINCT p.product_id) as product_count,
       SUM(od.quantity) as units_sold,
       ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
FROM categories c
INNER JOIN products p ON c.category_id = p.category_id
INNER JOIN order_details od ON p.product_id = od.product_id
GROUP BY c.category_id, c.category_name
ORDER BY revenue DESC;
" --csv > results/product_analysis/category_performance.csv

echo "   ✅ Product analysis exported (2 files)"

# ========================================
# EMPLOYEE PERFORMANCE EXPORTS
# ========================================
echo "👥 Exporting Employee Performance..."

# Employee Sales
psql -U postgres -d northwind -c "
SELECT e.first_name || ' ' || e.last_name as employee,
       e.title,
       COUNT(DISTINCT o.order_id) as orders,
       ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
FROM employees e
INNER JOIN orders o ON e.employee_id = o.employee_id
INNER JOIN order_details od ON o.order_id = od.order_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.title
ORDER BY revenue DESC;
" --csv > results/employee_performance/sales_by_employee.csv

echo "   ✅ Employee performance exported (1 file)"

# ========================================
# OPERATIONAL METRICS EXPORTS
# ========================================
echo "⚙️  Exporting Operational Metrics..."

# Shipping Performance
psql -U postgres -d northwind -c "
SELECT ship_country,
       COUNT(order_id) as orders,
       ROUND(AVG(shipped_date - order_date), 1) as avg_days_to_ship
FROM orders
WHERE shipped_date IS NOT NULL
GROUP BY ship_country
HAVING COUNT(order_id) >= 5
ORDER BY avg_days_to_ship DESC;
" --csv > results/operational_metrics/shipping_performance.csv

# Business Summary
psql -U postgres -d northwind -c "
SELECT 
    (SELECT COUNT(DISTINCT customer_id) FROM customers) as total_customers,
    (SELECT COUNT(*) FROM orders) as total_orders,
    (SELECT ROUND(SUM(unit_price * quantity * (1 - discount))::numeric, 2) 
     FROM order_details) as total_revenue,
    (SELECT COUNT(*) FROM products WHERE discontinued = 0) as active_products,
    (SELECT COUNT(DISTINCT country) FROM customers) as countries_served;
" --csv > results/operational_metrics/business_summary.csv

echo "   ✅ Operational metrics exported (2 files)"

# ========================================
# SUMMARY
# ========================================
echo ""
echo "=================================="
echo "✅ Export Complete!"
echo "=================================="
echo ""
echo "Files created:"
echo ""
find results -name "*.csv" -type f | sort
echo ""
echo "Total CSV files: $(find results -name "*.csv" -type f | wc -l)"
echo ""
echo "Next steps:"
echo "1. Review the CSV files"
echo "2. Create visualizations"
echo "3. Update README with key findings"
echo "=================================="
