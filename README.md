# OLIST Logistics Analysis — JET SODA SQL Practice

SQL practice queries on the [Brazilian E-Commerce (OLIST) dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from Kaggle, framed as real logistics and operations questions in the style of **JET SODA** (Just Eat Takeaway's Global Scoober Operations Data Analytics team) and **BOL.com**.

---

## Context

This repo documents SQL practice sessions for a **Medior Data Analyst** role focused on logistics operations. All questions are framed as stakeholder requests from two fictional analysts:

- **Lars Visser** — Head of Courier Operations, JET SODA Amsterdam. Focused on delivery performance, SLA breaches, and last-mile efficiency.
- **Beatriz Souza** — Senior Logistics Data Analyst, JET SODA Brazil Hub. Focused on seller performance, freight costs, and regional supply chain health.

---

## Dataset

| Table | Description |
|---|---|
| `olist_orders` | Order lifecycle — purchase, approval, delivery timestamps |
| `olist_order_items` | Line items — product_id, seller_id, price, freight_value |
| `olist_customers` | Customer data — customer_unique_id, state, city |
| `olist_sellers` | Seller data — seller_id, state, city |
| `olist_products` | Product catalogue — product_id, category_name |
| `olist_order_reviews` | Reviews — order_id, review_score |

---

## Queries

### Q1 — Delivery Performance Summary
**Stakeholder:** Lars Visser  
**Question:** Across all delivered orders, what % arrived Early, On Time, or Late?  
**Key concepts:** `CASE WHEN`, window function `%`, two-CTE chain  
**Key insight:** ~92% of OLIST orders arrive *early* — sellers pad estimated delivery dates aggressively. Lars's takeaway: tighten ETAs and use the buffer for route optimisation instead.

---

### Q2 — Seller Performance Scorecard
**Stakeholder:** Lars Visser  
**Question:** For each seller (10+ orders) — total orders, revenue, avg delivery days, on-time rate, avg review score. Rank by revenue.  
**Key concepts:** Multi-table JOIN, `AVG(flag) * 100` for rate (cleaner than `SUM/COUNT`), `HAVING`, `RANK() OVER`  
**Key insight:** On-time delivery rate is the best proxy for partner quality. Sellers below 70% on-time rate are candidates for courier network audit.

---

### Gap 5 — Customer Scorecard (Multi-table JOIN)
**Stakeholder:** Lars Visser + Beatriz Souza  
**Question:** For each customer (2+ orders) — total orders, revenue, avg review, avg delivery days, SLA breach %, and customer tier (VIP / Regular / Occasional). Rank by revenue.  
**Key concepts:** 4-table JOIN, granularity control in base CTE, SLA breach flag (1/0), `NULLIF`, `CASE` tier label, `RANK()`  
**Key insight:** VIP customers (>R$1000) consistently have 0% SLA breach and review scores above 4. 'Occasional' customers with high breach rates are the highest churn risk.

---

### Bonus — Freight Cost as % of Revenue by Category
**Stakeholder:** Beatriz Souza  
**Question:** For each category (100+ orders) — total orders, freight, avg freight per order, and freight as % of total transaction value.  
**Key concepts:** `JOIN order_items → products`, `NULLIF`, `COALESCE` for nulls, freight ratio formula  
**Key insight:** Categories where freight > 25% of total value need delivery fee repricing. Heavy/bulky categories typically breach this threshold.

---

## SQL Patterns Practiced

| Pattern | Used In |
|---|---|
| Two-CTE chain | Q1, Q2, Gap 5 |
| `SUM(COUNT(*)) OVER()` for window % | Q1 |
| `AVG(flag) * 100` for rate (vs SUM/COUNT) | Q2 |
| `CASE WHEN` tier label in final SELECT | Gap 5 |
| `NULLIF` for division safety | Gap 5, Bonus |
| `HAVING` after `GROUP BY` (not WHERE on alias) | Q2, Bonus |
| `RANK() OVER (ORDER BY ... DESC)` | Q2, Gap 5 |
| 4-table JOIN with granularity control | Gap 5 |
| `COALESCE` for NULL category names | Bonus |
| `DATE_PART('day', ts1 - ts2)` delivery days | Q2, Gap 5 |

---

## Lessons Learned

1. **Granularity is everything.** Before writing any CTE, ask: *what is one row here?* One order-item? One order? One customer? Getting this wrong causes silent aggregation bugs.
2. **`DISTINCT` + `GROUP BY` is redundant.** `GROUP BY` already guarantees one row per group. Don't layer `DISTINCT` on top.
3. **`> 2` vs `>= 2`.** "2+ orders" means `>= 2`, not `> 2`. Always re-read the business requirement.
4. **`AVG(flag)` is cleaner than `SUM(flag)/COUNT(*)`** for percentage rates when the flag is already 0/1.
5. **`NULLIF(expr, 0)` everywhere there's division.** Prevents runtime errors on zero denominators.
6. **Window functions need the right granularity first.** `LAG()` is only meaningful after you've aggregated to one row per time period. Applying it at customer-month level gives meaningless results.

---

## Next Practice Topics

- [ ] INTERVAL arithmetic (30-day revenue windows, SMLY)
- [ ] 7-day and 30-day rolling averages (`ROWS BETWEEN`)
- [ ] Seasonality analysis (90-day lag, monthly index)
- [ ] `FILTER(WHERE ...)` clause (weekday vs weekend, holiday vs regular)
- [ ] BOL advertising questions (ad ROI, category cannibalism, repeat purchase rate)
- [ ] Window functions: `PERCENT_RANK()`, `NTILE()`, `ROWS UNBOUNDED PRECEDING`

---

## Setup

Database: PostgreSQL via DataGrip  
Schema: `kaggle.*`  
Dataset source: [Kaggle — Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
