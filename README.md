# DataCo Supply Chain Analysis
**Sahil Changotra | github.com/sahilmchangotra**

A comprehensive SQL analytics project on the DataCo supply chain dataset — 180,519 orders across 5 global markets (2015–2018). Covers logistics, marketing, sales, process mining, interview prep, and mixed practice questions using advanced PostgreSQL window functions.

---

## 📦 Dataset

| Field | Detail |
|---|---|
| Database | dataco_db |
| Schema | supply_chain |
| Table | supply_chain.orders |
| Rows | 180,519 |
| Date Range | 2015-01-01 to 2018-01-31 |
| Markets | Africa, Europe, LATAM, Pacific Asia, USCA |
| Segments | Consumer, Corporate, Home Office |
| Shipping Modes | First Class, Same Day, Second Class, Standard Class |

**Standard Filter Used Throughout:**
```sql
WHERE order_status IN ('COMPLETE','CLOSED')
AND delivery_status != 'Shipping canceled'
```

**Critical Rules:**
- Always `COUNT(DISTINCT order_id)` — multiple line items per order
- Always `DATE_TRUNC('month', order_date)` for monthly grouping — never `EXTRACT(MONTH)` alone
- Always `supply_chain.orders` schema prefix
- SLA Breach: `days_for_shipping_real > days_for_shipment_scheduled + 1`
- First Class 100% late delivery — known data quality anomaly
- Oct 2017 volume collapse — ~70-100 orders/day drops to ~25-40

---

## 📁 Folder Structure

```
dataco-supply-chain-analysis/
├── sql/
│   ├── logistics/         → LQ1–LQ12
│   ├── marketing/         → MQ1–MQ9, BMQ1–BMQ2
│   ├── sales/             → SQ1–SQ4
│   ├── cohorts/           → LQ3b, LQ3c, MQ7b, MQ7c
│   ├── dll/               → DLL Q1–Q5
│   ├── interview_questions/ → IQ1–IQ15
│   └── mixed_practice/    → MX1–MX10
├── data/
└── tableau/
```

---

## ✅ LOGISTICS (LQ1–LQ12) — All Complete

| # | Question | Stakeholder | Key Concepts |
|---|---|---|---|
| LQ1 | Monthly on-time vs late + 3-month rolling avg + alert flag | Lars Visser (JET SODA) | Rolling AVG, CASE flag, FILTER(WHERE) |
| LQ2 | Shipping mode scorecard — real vs scheduled days, RANK() | Emma Clarke (DataCo) | AVG, RANK(), data_quality_flag |
| LQ3 | SLA breach rate by market, min 1,000 orders, ranked | Lars Visser | INTERVAL breach, HAVING, RANK() |
| LQ4 | Shipping mode YoY improvement — LAG(12) same month last year | Emma Clarke | LAG(12), PARTITION BY, trend flag |
| LQ5 | 7-day + 30-day rolling SLA breach daily + worsening flag | Emma Clarke | ROWS BETWEEN, two windows |
| LQ6 | Holiday season (Nov 15–Dec 31) vs regular period | Beatriz Souza (JET SODA) | GROUP BY CASE, EXTRACT month/day |
| LQ7 | Weekend vs weekday order volume and late delivery rate | Emma Clarke | EXTRACT DOW, FILTER(WHERE) |
| LQ8 | Ghost shipments — orders with shipping gap > 5 days by mode | Lars Visser | Date diff, FILTER(WHERE), data_quality_flag |
| LQ9 | NTILE(4) delivery speed tiers before/after July 2017 | Beatriz Souza | NTILE(4), period flag |
| LQ10 | Late delivery risk % by customer segment trend over time | Emma Clarke | 4-CTE pattern, DATE_TRUNC, LAG trend |
| LQ11 | Anomaly detection — real days > scheduled + 2 by shipping mode | Lars Visser | FILTER(WHERE), ratio flag |
| LQ12 | Seasonality index — which months have highest late rates | Beatriz Souza | Two-layer aggregation, RANK() |

**Key Findings:** ~57% late rate systemic. First Class 100% late (data anomaly). Second Class worst at 79.54%. Oct 2017 volume collapse. Holiday impact only +0.73pp. August worst seasonal month.

---

## ✅ MARKETING (MQ1–MQ9 + BMQ1–BMQ2) — All Complete

| # | Question | Stakeholder | Key Concepts |
|---|---|---|---|
| MQ1 | Monthly revenue by dept + YoY LAG(12) + growth % | Sophie van Dijk (bol) | LAG(12), YoY %, DATE_TRUNC |
| MQ2 | Discount simulation — 10% extra on below-avg categories | Noor Bakker (bol) | NTILE, UNION ALL, FILTER(WHERE) |
| MQ3 | Monthly seasonality index — highest revenue months | Sophie van Dijk | Two-layer aggregation, index calc |
| MQ4 | Weekend vs weekday revenue by customer segment | Noor Bakker | FILTER(WHERE), EXTRACT DOW |
| MQ5 | Summer sale impact (Jun–Aug) vs rest of year | Sophie van Dijk | CASE period, UNION ALL |
| MQ6 | RFM segmentation — Champions/Loyals/At Risk using NTILE(4) | Noor Bakker | NTILE, MAX ref date, CASE |
| MQ7 | Revenue cohort — revenue in 30 days after first order | Sophie van Dijk | INTERVAL 30 days, LEAD() |
| MQ8 | A/B test — Corporate vs Consumer revenue t-score | Noor Bakker | STDDEV, CROSS JOIN, t-score formula |
| MQ9 | Samsung scenario — Technology product ranking + market share | Daan (bol) | RANK(), market share %, window |
| BMQ1 | Peak month per department — DENSE_RANK | Daan | DENSE_RANK, PARTITION BY dept |
| BMQ2 | Pivot — department revenue by quarter | Sophie van Dijk | SUM(CASE WHEN quarter=N) |

**Key Findings:** Fan Shop 46% of all revenue. T-score 0.99 — Corporate vs Consumer NOT statistically different. 20.99% 90-day repeat rate. 43.27 days avg return.

---

## ✅ SALES (SQ1–SQ4) — All Complete

| # | Question | Key Concepts |
|---|---|---|
| SQ1 | 7-day rolling revenue + orders + top 5 revenue spike days | ROWS BETWEEN 6 PRECEDING, RANK() |
| SQ2 | INTERVAL 90 days — same customer repeat flag | INTERVAL 90, MIN() OVER() |
| SQ3 | Customer segment × department revenue matrix | CROSS JOIN, pivot-style |
| SQ4 | Profit ratio decline MoM by category | LAG, MoM, trend flag |

---

## ✅ COHORTS (LQ3b, LQ3c, MQ7b, MQ7c) — All Complete

| # | Question | Key Concepts |
|---|---|---|
| LQ3b | Pacific Asia monthly SLA breach cohort | DATE_TRUNC cohort + LAG trend |
| LQ3c | Customer 90-day repeat cohort — 20.99% repeat rate | LEAD(), INTERVAL 90 days |
| MQ7b | Monthly revenue cohort retention months 1–3 | DATE_TRUNC, INTERVAL, cohort retention |
| MQ7c | Category 30-day repeat rate by segment | MIN first order, INTERVAL 30 days |

---

## ✅ DLL PROCESS MINING (DLL Q1–Q5) — All Complete

| # | Question | Key Concepts |
|---|---|---|
| DLL Q1 | End-to-end process time — Fast/Normal/Slow/Critical buckets | Throughput time, CASE buckets |
| DLL Q2 | Process deviations — abnormal delivery by seller state | Deviation detection |
| DLL Q3 | Bottleneck report — avg time per stage, flag > 2x network avg | Bottleneck detection, CASE flag |
| DLL Q4 | Monthly process efficiency score | KPI + trend |
| DLL Q5 | Root cause — review ≤ 2, top 5 seller state + category | Root cause, multi-column GROUP BY |

---

## ✅ INTERVIEW QUESTIONS (IQ1–IQ15) — All Complete

| # | Company | Question | Key Concept |
|---|---|---|---|
| IQ1 | Flipkart | Daily active customers + 7-day rolling | Rolling AVG |
| IQ2 | Amazon | Consecutive month orders (gaps-and-islands) | ROW_NUMBER - date island |
| IQ3 | Zomato | Peak month per department DENSE_RANK | DENSE_RANK, PARTITION BY |
| IQ4 | Uber | Power seller flag (OLIST dataset) | FILTER(WHERE), ratio |
| IQ5 | Swiggy | Top 3 products per city DENSE_RANK | DENSE_RANK, PARTITION BY city |
| IQ6 | Delhivery | On-time % per route MoM + trend flag | LAG, trend flag |
| IQ7 | Flipkart | 7 consecutive order days | Gaps-and-islands, ROW_NUMBER |
| IQ8 | Amazon | Products dropped from top 10 revenue | Two-period JOIN, DENSE_RANK |
| IQ9 | Meesho | Seller GMV rank per category (OLIST) | DENSE_RANK PARTITION BY category |
| IQ10 | Nykaa | MoM buyer retention (OLIST) | Cohort + LEFT JOIN INTERVAL |
| IQ11 | BigBasket | Second highest order value per customer | DENSE_RANK = 2 |
| IQ12 | DHL/FedEx | Delayed shipments > 2x expected transit | FILTER(WHERE) + ratio |
| IQ13 | Uber Eats | Running total reset monthly | SUM() OVER PARTITION BY month |
| IQ14 | Ola | Peak hour per city | EXTRACT(HOUR), DENSE_RANK |
| IQ15 | Flipkart | Median without PERCENTILE_CONT | FLOOR/CEIL + ROW_NUMBER trick |

---

## ✅ MIXED PRACTICE (MX1–MX10) — All Complete

| # | Question | Key Concepts |
|---|---|---|
| MX1 | Top 3 worst delivery days per market | DENSE_RANK, PARTITION BY market |
| MX2 | Product profit rank per dept (Hero/Retire flags) | ROW_NUMBER, profit ratio |
| MX3 | Worst month per shipping mode + market | PARTITION BY 2 columns |
| MX4 | Daily customers 7-day rolling + rank spike days | ROWS BETWEEN, RANK() |
| MX5 | Top customer per segment + department | DENSE_RANK PARTITION BY 2 columns |
| MX6 | Rank months by delay gap per market + mode | PARTITION BY 2, DENSE_RANK |
| MX7 | Top 3 city pairs by late rate | Route concat, DENSE_RANK global |
| MX8 | Pivot orders by mode × quarter | FILTER(WHERE EXTRACT QUARTER) |
| MX9 | Rank orders by value + flag if most recent = highest | FIRST_VALUE, DENSE_RANK |
| MX10 | Daily active customers per market 30-day rolling | ROWS BETWEEN 29 PRECEDING, PARTITION BY market |

---

## 🏆 SQL CONCEPTS MASTERED

| Concept | Where Used |
|---|---|
| Rolling windows ROWS BETWEEN | LQ1, LQ5, SQ1, MX4, MX10 |
| LAG/LEAD | LQ4, MQ1, SQ4, IQ2, IQ10 |
| NTILE | LQ9, MQ2, MQ6 |
| RANK/DENSE_RANK/ROW_NUMBER | Throughout |
| UNION ALL | LQ6, MQ5 |
| Pivot SUM CASE WHEN / FILTER | BMQ2, MX8 |
| CROSS JOIN t-score | MQ8 |
| RFM Segmentation | MQ6 |
| Cohort INTERVAL + LEAD | LQ3c, MQ7, IQ10 |
| Two-layer aggregation | LQ12, MQ3 |
| FIRST_VALUE | MX9 |
| Anomaly detection | LQ11, IQ12 |
| Gaps-and-islands | IQ2, IQ7 |
| Two-period JOIN | MQ1, IQ8 |
| PARTITION BY 2 columns | MX3, MX5, MX6 |
| Median without PERCENTILE_CONT | IQ15 |
| Running total reset by partition | IQ13 |
| Route concatenation | MX7 |

---

## 🔑 KEY FINDINGS SUMMARY

| Finding | Value |
|---|---|
| Overall late delivery rate | ~57% systemic across ALL dimensions |
| First Class late rate | 100% — data quality anomaly |
| Second Class late rate | 79.54% — worst real performer |
| Fan Shop revenue share | 46% of all revenue |
| Corporate vs Consumer t-score | 0.99 — NOT statistically different |
| 90-day repeat rate | 20.99% |
| Avg days to return | 43.27 days |
| Holiday season delivery impact | +0.73pp — not meaningful |
| Worst seasonal month | August (index 1.0226) |
| Worst city pair late rate | Edinburgh → Caguas 87.5% |
| Oct 2017 volume collapse | All markets affected |

---

*Project by Sahil Changotra | Stack: PostgreSQL / DataGrip • Tableau Public • GitHub*
*Sessions: March 30 – April 12, 2026*