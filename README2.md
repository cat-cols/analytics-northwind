# Northwind SQL Business Intelligence Analysis

**Advanced SQL analysis of e-commerce operations demonstrating business insight generation and data-driven decision-making**

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?logo=postgresql)
![Status](https://img.shields.io/badge/Status-Complete-success)
![Queries](https://img.shields.io/badge/Queries-27-blue)

---

## 🎯 Project Overview

Business intelligence analysis of the **Northwind** e-commerce database using **advanced SQL** (CTEs, window functions, statistical functions) to translate raw transactional data into **actionable business insights**.

- **Database:** Northwind (PostgreSQL)
- **Scope:** 830 orders | 2,155 line items | 91 customers | 21 countries
- **Time Period:** July 1996 – May 1998
- **Total Revenue Analyzed:** **$1,265,793**

---

## ✅ What This Project Proves

✅ You can write complex, production-grade SQL
✅ You understand business metrics (LTV, segmentation, retention, growth, concentration)
✅ You can detect and communicate data pitfalls (partial-year comparisons, edge cases)
✅ You can turn analysis into decisions and recommendations
✅ You can organize work like an analyst/analytics engineer (reproducible runs + exports)

---

## 🧱 Database Schema (High-Level)

**Tables used:**
- Customers (91)
- Orders (830)
- Order Details (2,155)
- Products
- Employees
- Shippers
- Categories / Suppliers (for product & ops cuts)

> **Schema diagram:** add an image at `assets/northwind_schema.png` and link it here when ready.  
> Example: `![Northwind Schema](assets/northwind_schema.png)`

---

## 📁 Project Structure

```text
analytics-northwind/
├── sql/                          # SQL query files (27 queries)
│   ├── 01_customers.sql          # Customer analysis (6 queries)
│   ├── 02_sales.sql              # Sales trends (5 queries)
│   ├── 03_products.sql           # Product analysis (5 queries)
│   ├── 04_employees.sql         # Employee performance (5 queries)
│   └── 05_operations.sql        # Operational metrics (6 queries)
├── outputs/                      # Exported results (CSVs)
│   ├── customer_analysis/
│   ├── sales_trends/
│   ├── product_analysis/
│   ├── employee_performance/
│   └── operational_metrics/
├── database/
│   └── northwind.sql             # Database setup script
├── export_all_results.sh         # Automated export script
└── README.md
```

---

## 📊 Executive Summary

| Metric | Value | Why it matters |
|--------|-------|----------------|
| **Total Revenue** | **$1.27M** | Overall performance baseline |
| **Customers** | **91** | Multi-country B2B footprint |
| **Repeat Rate** | **98.88%** | Retention is not the bottleneck |
| **1997 YoY Growth** | **+196.56%** | Clear acceleration |
| **Top 10 Revenue Share** | **~45%** | Revenue concentration risk/opportunity |

---

## ⚠️ Data Completeness Note (Important)

Northwind contains:
- **1996:** Jul–Dec (6 months)
- **1997:** Jan–Dec (full year)
- **1998:** Jan–May (5 months)

So a raw **1998 decline** is misleading because it compares a partial year to a full year.

**Annualized 1998 projection:**
- Jan–May 1998: **$440,624**
- Monthly avg: **$88,125**
- Projected full-year: **$1,057,493**
- **True projected YoY growth vs 1997: +71.4%**

---

## 🔑 Key Business Findings

### 💰 Customer Intelligence

#### Top 10 Customers Drive ~45% of Revenue

| Customer | Country | Orders | Revenue | Avg Order Value |
|----------|---------|--------|---------|----------------|
| QUICK-Stop | Germany | 28 | $110,277 | $3,938 |
| Ernst Handel | Austria | 30 | $104,875 | $3,496 |
| Save-a-lot Markets | USA | 31 | $104,362 | $3,366 |
| Rattlesnake Canyon | USA | 18 | $51,098 | $2,839 |
| Hungry Owl | Ireland | 19 | $49,980 | $2,630 |

**Insight:** Save-a-lot places the most orders, but QUICK-Stop is highest value per order.  
**Action:** Treat them differently:  
- QUICK-Stop → premium service / relationship protection  
- Save-a-lot → incentives to increase basket size

#### Customer Retention: Best-in-Class (Within Dataset)

```text
Total customers: 89
One-time buyers: 1 (1.12%)
Repeat customers: 88 (98.88%)
```

**Interpretation:** Strong B2B reorder behavior → growth is more likely to come from:
- acquiring new customers
- increasing order size / frequency in high-potential accounts

#### Customer Segmentation (RFM-Style)

| Segment | Customers | Avg Spent | % of Base |
|---------|-----------|-----------|-----------|
| VIP | 6 | $75,027 | 6.7% |
| High Value | 34 | $18,386 | 38.2% |
| Regular | 26 | $5,535 | 29.2% |
| Occasional | 23 | $2,026 | 25.8% |

**Pareto validation:** Top VIPs (6.7%) generate roughly **~$450K (~35% of revenue)**.

**Recommendation:** A focused VIP program is low effort, high ROI.  
A single additional VIP-sized account is worth roughly **~$75K** (based on observed VIP avg spend).

---

### 📈 Sales Performance & Trends

#### Year-Over-Year Growth

| Year | Revenue | Growth vs Prior Year |
|------|---------|---------------------|
| 1996 | $208,084 | — (partial year) |
| 1997 | $617,085 | **+196.56%** |
| 1998 | $440,624 | -28.60%* |

\*Not comparable due to partial-year coverage (see data completeness note).  
**True direction:** Growth continues strongly when normalized.

---

### 🛍️ Product Performance

#### Top 5 Products by Revenue

| Product | Category | Units Sold | Revenue | Revenue % |
|---------|----------|------------|---------|-----------|
| Côte de Blaye | Beverages | 623 | $141,397 | 11.2% |
| Thüringer Rostbratwurst | Meat/Poultry | 746 | $80,369 | 6.3% |
| Raclette Courdavault | Dairy | 1,496 | $71,156 | 5.6% |
| Tarte au sucre | Confections | 1,083 | $47,235 | 3.7% |
| Camembert Pierrot | Dairy | 1,577 | $46,825 | 3.7% |

**Key finding:** A premium beverage (Côte de Blaye) drives **11.2%** of all revenue → high-margin items matter.

#### Category Performance

| Category | Products | Units Sold | Revenue | % of Total |
|----------|----------|------------|---------|------------|
| Beverages | 12 | 9,532 | $267,868 | 21.2% |
| Dairy Products | 10 | 9,149 | $234,507 | 18.5% |
| Confections | 13 | 7,906 | $167,357 | 13.2% |
| Meat/Poultry | 6 | 4,199 | $163,022 | 12.9% |

**Recommendation:** Focus product strategy on **Beverages + Meat/Poultry** (high revenue efficiency per SKU).

---

### 👥 Employee Performance

#### Top Performers

| Employee | Title | Orders | Revenue | Orders/Month* |
|----------|-------|--------|---------|---------------|
| Margaret Peacock | Sales Rep | 156 | $232,891 | ~8.7 |
| Janet Leverling | Sales Rep | 127 | $202,813 | ~7.1 |
| Nancy Davolio | Sales Rep | 123 | $192,108 | ~6.8 |
| Andrew Fuller | VP Sales | 96 | $166,538 | ~5.3 |
| Laura Callahan | Inside Sales | 104 | $126,862 | ~5.8 |

\*Approx based on ~18 months of data.

**Insights:**
- Top 3 reps generate **~49.5%** of revenue → strong concentration
- ~3.4x gap between top and bottom performers → training + territory review opportunity

**Recommendation:** Capture the top rep playbook, then formalize mentorship + territory fairness review.

---

### 📦 Operational Metrics

#### Shipping Performance by Country

| Country | Orders | Avg Days to Ship | Assessment |
|---------|--------|------------------|------------|
| Austria | 139 | 9.2 | Acceptable |
| Germany | 122 | 9.0 | Acceptable |
| USA | 122 | 6.9 | Good (benchmark) |
| France | 77 | 8.5 | Acceptable |
| Brazil | 83 | 10.2 | Needs improvement |

**Recommendation:** Investigate Brazil delays (distance/customs/shipper mix). Consider regional fulfillment options for consistent >10 day markets.

---

## 💻 Technical Skills Demonstrated

### Advanced SQL Techniques

| Technique | Usage | Examples |
|----------|-------|----------|
| Window Functions | LAG, ROW_NUMBER, PARTITION BY, SUM OVER | 7, 14, 19, 24 |
| CTEs | Multi-level CTE logic | 2, 4, 7, 17, 19, 24 |
| Statistical Functions | PERCENTILE_CONT (medians) | 10, 21 |
| Self-Joins | Bundling analysis | 15 |
| FILTER | Conditional aggregations | 2 |
| NULL Safety | COALESCE, NULLIF | Throughout |
| Precision | ::numeric casting | Every aggregation |

### Complexity Breakdown

- **Intermediate:** ~40% (CTEs, subqueries, modular logic)
- **Advanced:** ~60% (window functions, self-joins, multi-stage analytics)

---

## 📌 Sample Query: Customer Lifetime Value

```sql
-- Demonstrates: CTEs, window functions, business metrics
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
  ROUND(AVG(ot.order_total), 2) AS avg_order_value
FROM customers c
JOIN order_totals ot ON c.customer_id = ot.customer_id
GROUP BY c.customer_id, c.company_name, c.country
ORDER BY lifetime_value DESC
LIMIT 20;
```

**Business value:** Identifies high-value accounts to prioritize for retention programs, pricing strategy, and sales focus.

---

## 🚀 How to Run This Analysis

### Prerequisites
- PostgreSQL 16+
- `psql`

### Setup

```bash
# 1) Create database
createdb northwind

# 2) Load data
psql -d northwind -f database/northwind.sql

# 3) Verify install
psql -d northwind -c "SELECT COUNT(*) FROM customers;"
# Expected: 91

# 4) Run query packs (recommended)
psql -d northwind -f sql/01_customers.sql
psql -d northwind -f sql/02_sales.sql
psql -d northwind -f sql/03_products.sql
psql -d northwind -f sql/04_employees.sql
psql -d northwind -f sql/05_operations.sql

# 5) Export everything
./export_all_results.sh
```

---

## 📈 Business Impact & Recommendations

| Recommendation | Expected Impact | Difficulty |
|----------------|----------------|------------|
| VIP Retention Program | +$75K per VIP-equivalent account | Low |
| Top Rep Mentorship Program | +15–20% uplift for developing reps | Medium |
| Brazil Shipping Investigation | Reduce cycle time by 2–3 days | Medium |
| Beverages Category Focus | +10–15% category revenue | Low |
| Confections SKU Rationalization | Reduce costs, focus on winners | High |

---

## 📝 Query Index

### Customer Analysis (`01_customers.sql`)
1. Top 10 Customers by Revenue  
2. Customer Retention Analysis (90-day window)  
3. Customer Lifetime Value  
4. Customer Lifetime Value (Alt. Method)  
5. Customer Segmentation (RFM-style)  
6. Geographic Distribution  

### Sales Trends (`02_sales.sql`)
7. Monthly Sales Trend  
8. Year-Over-Year Growth  
9. Quarterly Performance  
10. Day of Week Analysis  
11. Average Order Frequency  

### Product Analysis (`03_products.sql`)
12. Top Products by Revenue  
13. Category Performance  
14. Slow-Moving Inventory  
15. Product Pricing Analysis  
16. Product Bundling Opportunities  

### Employee Performance (`04_employees.sql`)
17. Employee Sales Performance  
18. Employee Efficiency Metrics  
19. Employee Territory Performance  
20. Employee Year-Over-Year Growth  
21. Top Employee–Product Combinations  

### Operational Metrics (`05_operations.sql`)
22. Shipping Performance by Country  
23. Shipper Performance Comparison  
24. Late Orders Analysis  
25. Revenue Concentration (Pareto)  
26. Order Fulfillment Cycle Time  
27. Executive Dashboard Summary  

---

## 📧 Contact & Portfolio

**Brandon Hardison**  
Data Analyst — Portland, OR  

- Email: brandon.hardison.555@gmail.com  
- GitHub: github.com/cat-cols  
- LinkedIn: linkedin.com/in/brandon-hardison  

---

## 🙏 Acknowledgments

- Northwind sample database (ported to PostgreSQL)
- Data source: GitHub repo `pthom/northwind_psql`

---

## 📄 License

Portfolio demonstration project.

**Last Updated:** February 17, 2026  
**Status:** ✅ Complete & Production-Ready
