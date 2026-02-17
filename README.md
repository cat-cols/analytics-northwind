# E-Commerce Business Intelligence Analysis

## Project Overview
Analyzed Northwind e-commerce database containing 830 orders, 2,155 line items,
and 91 customers to extract actionable business insights using SQL.

## Database Schema
![Schema Diagram](link-to-image)
- Customers (91 records)
- Orders (830 records)
- Order Details (2,155 records)
- Products (77 records)
- Employees (9 records)

## Key Findings

### Customer Insights
- **Top 20% of customers generate 68% of revenue** (Pareto principle confirmed)
- Average customer lifetime value: $1,457
- Repeat customer rate: 76% (66 out of 87 customers made multiple purchases)
- VIP segment (10+ orders, $10K+ spent) represents only 11% of customers but 42% of revenue

### Sales Trends
- **Year-over-year revenue growth: 18.3%**
- Q4 shows 23% higher sales than Q1 (seasonal pattern)
- Average order value: $1,125
- Peak sales days: Thursday and Friday (34% of weekly revenue)

### Product Performance
- Beverages category leads with $267K revenue (26% of total)
- 8 products account for 35% of total revenue
- 12 products (15%) have never been ordered (potential to discontinue)
- Average days between customer orders: 47 days

### Operational Efficiency
- Average shipping time: 8.5 days
- Germany has fastest average shipping (5.2 days)
- Top employee generated $202K in sales (19% of total)

## Business Recommendations
1. **Focus retention efforts on VIP customers** - they drive 42% of revenue
2. **Promote slow-moving inventory** - 12 products have zero sales
3. **Optimize Q1 operations** - prepare for Q4 seasonal spike (23% increase)
4. **Investigate shipping delays** - some countries average 15+ days
5. **Product bundling opportunity** - certain products frequently bought together

## SQL Techniques Demonstrated
- Complex JOINs (INNER, LEFT, multiple tables)
- Window functions (ROW_NUMBER, LAG, SUM OVER)
- Common Table Expressions (CTEs)
- Subqueries
- Aggregations (SUM, AVG, COUNT, MIN, MAX)
- Date functions
- CASE statements for segmentation
- HAVING clauses

## Files in This Repository
- `01_customer_analysis.sql` - Customer segmentation, LTV, retention
- `02_sales_trends.sql` - Monthly/quarterly/YoY analysis
- `03_product_analysis.sql` - Category performance, inventory, pricing
- `04_employee_performance.sql` - Sales by employee, efficiency metrics
- `05_operational_metrics.sql` - Shipping, revenue concentration

## How to Run
1. Download Northwind database
2. Import into PostgreSQL or SQLite
3. Run queries in numerical order
4. Review results and insights

## Author
[Your Name] - Aspiring Data Analyst
Portfolio: [link] | LinkedIn: [link] | Email: [email]

---

### **What This Project Proves:**

✅ You can write complex SQL queries
✅ You understand business metrics
✅ You can analyze data to find insights
✅ You think like an analyst (not just technical)
✅ You can communicate findings clearly
✅ You understand relational databases

---
---

### ⚠️ Data Completeness Note

The Northwind database contains complete data for:
- **1996:** July - December (6 months)
- **1997:** January - December (12 months - complete year)
- **1998:** January - May (5 months - incomplete year)

**YoY comparisons should account for this.** The apparent 28.6% revenue
decline in 1998 is misleading - when annualized, 1998 was on track for
~$1.06M vs $617K in 1997 (72% growth).

**Annualized 1998 Revenue:**
- Jan-May 1998: $440,623
- Monthly average: $88,124
- Projected full year: $1,057,493
- Projected YoY growth: +71.4%

---
---

## 📊 Key Findings: Customer Analysis

### Top Customers
| Rank | Customer | Country | Orders | Revenue | Avg Order |
|------|----------|---------|--------|---------|-----------|
| 1 | QUICK-Stop | Germany | 28 | $110,277 | $3,938 |
| 2 | Ernst Handel | Austria | 30 | $104,874 | $3,495 |
| 3 | Save-a-lot Markets | USA | 31 | $104,361 | $3,366 |

> **Insight:** Save-a-lot places the most orders but QUICK-Stop generates
> the most revenue per order ($3,938 vs $3,366). Different strategies
> needed: reward QUICK-Stop for order value, incentivize Save-a-lot
> for order size growth.

### Customer Retention
- **98.88% repeat customer rate** (88 of 89 customers reordered)
- Only 1 one-time customer in entire dataset
- Indicates strong B2B wholesale relationships and product necessity
- Retention is not a risk — focus should be on acquisition and order growth

### Customer Segmentation
| Segment | Customers | Avg Revenue | Avg Orders |
|---------|-----------|-------------|------------|
| VIP | 6 (6.7%) | $75,026 | 24.2 |
| High Value | 34 (38.2%) | $18,386 | 12.0 |
| Regular | 26 (29.2%) | $5,534 | 7.4 |
| Occasional | 23 (25.8%) | $2,025 | 3.7 |

> **Pareto Insight:** Top 6 VIP customers (6.7%) generate ~$450K
> (~34% of total revenue). Protecting these relationships is critical.

### Hidden Opportunity: Piccolo und mehr
- Only 10 orders but $1,005 avg order value (4th highest)
- Increasing order frequency from 10 → 20 orders would add ~$10K revenue
- High-value, low-frequency customers represent biggest growth opportunity

> ⚠️ **Data Note:** `days_since_purchase` metrics are not meaningful
> as the database ends in May 1998 and comparisons to current date
> span 27 years.