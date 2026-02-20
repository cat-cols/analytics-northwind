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
# 4. Add Parameter Actions to Tableau Dashboard
```

## My recommended “merge plan” (minimal edits, maximum gain)

1. Add **Schema / Data Model** section (short).
2. Add **What This Project Proves** bullets.
3. Move/echo the **Data Completeness note** so it appears before any YoY interpretation.
4. Add a **one-screen Key Findings** bullet list for skimmers.
5. Do **not** copy any of B’s conflicting numbers.

---

## ✅ Project setup
- [x] Confirm PostgreSQL running locally (Homebrew service)
- [x] Confirm `northwind` database exists and schema loaded
- [x] Add `.gitignore` (ignore `outputs/`, `.DS_Store`, local env files)
- [x] Create folders:
  - [x] `sql/` (queries)
  - [x] `outputs/` (generated CSVs)
  - [x] `docs/` (notes, assumptions, screenshots)
  - [x] `src/` (optional scripts for export/automation)
- [] Create ERD

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



---
---

Yep — there **are** a few things in **B** worth stealing for **A**, but there are also a couple landmines in B you should **not** import because they conflict with (what looks like) your real computed results in A.

## The best things from B to add into A

### 1) Add a “What this project proves” section (recruiter-friendly)

Your A is impressively thorough, but it’s *so* thorough that a skim-reader may miss the punchline: what skills you’re signaling.

Drop this near the top (after Project Overview) or near the end:

* ✅ Complex SQL (joins, CTEs, window functions)
* ✅ Business metrics thinking (LTV, retention, Pareto, cohorts)
* ✅ Data quality skepticism (partial-year handling, null safety)
* ✅ Insight → recommendation translation

This is pure portfolio UX: it helps non-technical readers “get it” instantly.

### 2) Add a short schema section (with a real diagram or table list)

B has a “Database Schema” section. A currently *explains structure via folders* (good) but not *data model*.

Add a small section like:

* Key tables: customers, orders, order_details, products, employees, shippers
* Grain: line items (order_details), order header (orders)

If you can add a real schema image later, great — but even a bullet list helps a ton.

💡💡 If you don’t have a diagram yet, you can generate one quickly by screenshotting an ERD (DBeaver / pgAdmin) or using a simple dbdiagram tool, then link it in the README.

### 3) Add “How to run” clarity from B, but keep A’s better version

A already has a strong runbook. What you *could* import from B is the **“Run queries in numerical order”** concept (simple + reassuring).

Add one line under “How to Run”:

> Queries are organized by business domain and can be run top-to-bottom within each file for a narrative flow.

### 4) Add one “Key Findings” super-summary block (shorter than your full Executive Summary)

Your A has a great Executive Summary table. Consider adding a **3–5 bullet “headline insights”** right below it for skimmers:

* Revenue concentrated: Top 10 customers = 45%
* Beverages + Dairy dominate category revenue
* Top 3 reps drive ~50% of revenue
* Shipping lag in Brazil vs benchmark USA

That’s the “manager brain” version.

### 5) Keep (and reposition) the Data Completeness note for maximum credibility

Both A and B have it — yours in A is excellent. The only improvement: move that warning **higher** (right before YoY table) and/or add a one-line callout near the top like:

> **Data caveat:** 1996 and 1998 are partial years; YoY comparisons are adjusted accordingly.

That single sentence signals “this person doesn’t hallucinate conclusions from incomplete data.”

---

## Things from B you should NOT copy (unless you re-verify)

B contains numbers that conflict with A, which would look like you’re mixing datasets or guessing:

* **Repeat rate:** B says 76% (66/87), A says 98.88% (88/89). Those can’t both be true.
* **YoY growth:** B says 18.3%, A says +196.56% for 1997. Huge mismatch.
* **Germany fastest shipping:** B says 5.2 days, A shows Germany 9.0 and USA 6.9.

So: don’t import B’s specific metrics unless you re-run and confirm them. A reads like the “real” one.

💡💡 If you want to keep B’s phrasing, convert those into **metric-less statements** (e.g., “Revenue is concentrated among top customers”) *only if* you already have the exact number in A.

---

## Two upgrades A is missing that B hints at

### A) Replace the fake image link

B has `![Schema Diagram](link-to-image)` which is currently a placeholder. A doesn’t have a diagram, which is fine — but don’t add a placeholder link. Either:

* add a real image, or
* omit the image line and just list tables + grain.

### B) Add a tiny “Files in repo” section for ultra-fast navigation

A already has the folder tree (good), but a short list like B’s helps:

* `sql/01_customers.sql` — segmentation, retention, LTV
* `sql/02_sales.sql` — monthly/quarterly/YoY
  …etc.

Yes, it’s redundant. Redundancy is good in READMEs because people skim in weird ways.

💡💡 Extra nerd polish: your title says “e-commerce” but Northwind is often framed as wholesale/trading. If your analysis supports B2B/wholesale behavior (your retention insight suggests it does), consider one subtle wording tweak: “order management / wholesale distribution” instead of pure e-commerce. That reads more realistic to hiring managers.

You’ve basically built a BI case study disguised as a SQL repo — which is exactly the kind of camouflage that gets interviews.
