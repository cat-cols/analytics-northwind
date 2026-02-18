# TODO — Northwind Analytics (PostgreSQL)

Last updated: 2026-02-17

## Goals
- Answer common business questions using reproducible SQL.
- Produce clean, reviewable outputs (CSV) and a short write-up (README) that explains assumptions and key findings.
- Keep queries finance-safe (net revenue math, explicit definitions, consistent naming).

---
**Quicklist:**
```bash
# 1. Fix formatting consistency (15 min)
# Go through each file, ensure consistent indentation
# 2. settle on output directory structure
# 3. Add to your root README.md:
a Screenshots section with the 6 charts (or 3 best charts)
a How to reproduce section:
load DB
run export script
run chart script
```

---

## ✅ Project setup
- [ x] Confirm PostgreSQL running locally (Homebrew service)
- [ ] Confirm `northwind` database exists and schema loaded
- [x] Add `.gitignore` (ignore `outputs/`, `.DS_Store`, local env files)
- [ ] Create folders:
  - [x] `sql/` (queries)
  - [x] `outputs/` (generated CSVs)
  - [x] `docs/` (notes, assumptions, screenshots)
  - [ ] `src/` (optional scripts for export/automation)

---

## ✅ Data understanding and definitions
- [ ] Document schema relationships in `README.md`
  - customers → orders → order_details
  - products → categories
- [ ] Define revenue once and reuse it everywhere:
  - [ ] `net_line_revenue = unit_price * quantity * (1 - discount)`
  - [ ] Exclusions: tax, freight, refunds, returns (not present in dataset)
- [ ] Confirm `discount` is a rate in [0, 1] (spot check)

---

## SQL deliverables

### Products (`sql/03_products.sql`)
- [x] Top products by net revenue
- [x] Category revenue + revenue per unit
- [x] Slow-moving inventory report
- [x] Pricing vs category average (list price)
- [x] Bundling / co-occurrence pairs
- [ ] Add “support” metric to bundling output (orders_bought_together / total_orders)
- [ ] Add a note clarifying list price vs transaction price in pricing query
- [ ] Add `\set ON_ERROR_STOP on` at top of script
- [x] Add a Query Index
- [ ] 

### Customers (`sql/01_customers.sql`)
- [x] Top customers by net revenue
- [x] Repeat buyers (definition: >1 order)
- [x] Retention proxy (repeat within 90 days)
- [x] CLV with avg order value (order_totals CTE)
- [x] RFM-style segmentation
- [x] Geographic distribution by country
- [ ] Anchor recency to dataset `MAX(order_date)` (avoid “10k days” effect)
- [ ] Rename metrics for clarity:
  - [ ] `avg_order_line_net_revenue` vs `avg_order_value`
  - [ ] `avg_line_items_per_order` (not “lines”)
- [ ] Add sanity-check queri
