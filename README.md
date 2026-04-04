# DataCo Smart Supply Chain Analytics

**SQL Analysis Portfolio | Logistics & Marketing Intelligence**

Sahil Changotra • The Hague, Netherlands • April 2026

---

## 📋 Repository Overview

| Field | Detail |
|---|---|
| Dataset | DataCo Smart Supply Chain — Kaggle |
| Database | dataco_db — Schema: supply_chain — Table: supply_chain.orders |
| Rows | 180,519 orders — Date Range: 2015-01-01 to 2018-01-31 |
| Markets | Africa, Europe, LATAM, Pacific Asia, USCA |
| Segments | Consumer, Corporate, Home Office |
| Shipping Modes | First Class, Same Day, Second Class, Standard Class |
| Target Roles | Data Analyst — JET SODA Amsterdam \| BOL Retail Media Netherlands |
| Stack | PostgreSQL / DataGrip • Python (Jupyter) • Tableau Public • GitHub |

> ⚠️ **Critical Data Quality Issue — First Class Shipping**
> First Class shipping mode has 100% late delivery rate with no on-time records. This is a known DataCo dataset anomaly. All queries involving shipping mode include a `data_quality_flag` column to flag this explicitly.

> 📉 **Volume Drop — October 2017 Onwards**
> Order volume drops from ~70–100 orders/day to ~25–40 orders/day from October 2017. Results from this period should be interpreted with caution.

---

## 🔧 Standard Query Rules

| Rule | Definition |
|---|---|
| Standard Filter | `WHERE order_status IN ('COMPLETE', 'CLOSED') AND delivery_status != 'Shipping canceled'` |
| SLA Breach | `days_for_shipping_real > days_for_shipment_scheduled + 1` |
| Late Delivery | `delivery_status = 'Late delivery'` |
| Schema Prefix | Always use `supply_chain.orders` — never just `orders` |
| First Class Flag | Always add `data_quality_flag` column — 100% late delivery, DataCo anomaly |

---

## 📁 Repository Structure

```
dataco-supply-chain-analysis/
├── sql/
│   ├── logistics/       ← LQ1–LQ12 ✅ Complete
│   ├── marketing/       ← MQ1–MQ9 + BMQ1–2 + Pivot 1–2 ✅ Complete
│   ├── sales/           ← SQ1–SQ4 ✅ Complete
│   ├── cohorts/         ← LQ3b, LQ3c, MQ7b, MQ7c 🔜 Pending
│   └── dll/             ← DLL Q1–Q5 🔜 Pending
├── data/                ← Exported CSVs from DataGrip
├── tableau/             ← Tableau workbook + screenshots (this weekend)
└── README.md
```

---

## 🚚 Logistics SQL Questions (LQ1–LQ12) — ✅ All Complete

**Stakeholders:** Lars Visser (JET SODA Logistics Ops) | Emma Clarke (DataCo Network Planning) | Beatriz Souza (JET SODA Senior Logistics)

| # | Business Question | Stakeholder | SQL Concepts | Key Finding |
|---|---|---|---|---|
| LQ1 | Monthly on-time vs late delivery rate + 3-month rolling avg + alert flag | Lars Visser | Rolling AVG, CASE flag, FILTER(WHERE) | Every month Alert — 52–60% late rate systemic |
| LQ2 | Shipping mode scorecard — real vs scheduled days, delay gap, RANK() | Emma Clarke | AVG, RANK(), gap calc, data_quality_flag | Second Class worst: +1.96 day gap, 79.54% late |
| LQ3 | SLA breach rate by market, minimum 1,000 orders, ranked | Lars Visser | INTERVAL breach, HAVING, RANK() | Pacific Asia worst 23.92%, Europe best 22.86% |
| LQ4 | Shipping mode YoY improvement — LAG(12) same month last year | Emma Clarke | LAG(12), PARTITION BY, trend flag | Standard Class only improving mode (H2 2017) |
| LQ5 | 7-day + 30-day rolling SLA breach daily + worsening flag | Emma Clarke | ROWS BETWEEN, two windows, WHERE >= 5 | First worsening: Jan 17, 2015 |
| LQ6 | Holiday season (Nov 15–Dec 31) vs regular period | Beatriz Souza | GROUP BY CASE, EXTRACT month/day | Holiday only +0.73pp worse — not meaningful |
| LQ7 | Weekend vs weekday order volume and late delivery rate | Emma Clarke | EXTRACT DOW, FILTER(WHERE) | Weekend only +0.37pp — not meaningful |
| LQ8 | Ghost shipments — orders with shipping gap > 5 days by mode | Lars Visser | Date diff, FILTER(WHERE), data_quality_flag | Second Class only: 38.13% ghost rate |
| LQ9 | NTILE(4) delivery speed tiers before/after July 2017 | Beatriz Souza | NTILE(4), period flag before NTILE | Fastest tier: 1.67 → 1.70 days (no improvement) |
| LQ10 | Late delivery risk % by customer segment trend over time | Emma Clarke | 4-CTE pattern, DATE_TRUNC, LAG trend | All segments identical at ~57% — systemic |
| LQ11 | Anomaly detection — real days > scheduled + 2 by shipping mode | Lars Visser | FILTER(WHERE), ratio flag, gap detection | Second Class only: 38.13% anomaly rate |
| LQ12 | Seasonality index — which months have highest late rates | Beatriz Souza | Two-layer aggregation, AVG OVER(), RANK() | August worst (1.02), January best (0.98) |

---

## 📈 Marketing SQL Questions (MQ1–MQ9) — ✅ All Complete

**Stakeholders:** Sophie van Dijk (bol category marketing) | Noor Bakker (bol performance marketing) | Daan (bol product ops)

| # | Business Question | Stakeholder | SQL Concepts | Key Finding |
|---|---|---|---|---|
| MQ1 | Monthly revenue by department + YoY LAG(12) + growth % | Sophie van Dijk | LAG(12), YoY %, DATE_TRUNC, New/Growing/Declining flag | Fan Shop collapsed -99% from Oct 2017 |
| MQ2 | Discount simulation — 10% extra on below-avg categories | Noor Bakker | NTILE, UNION ALL, FILTER(WHERE), projected revenue | 41/49 categories below avg — 20% revenue impact |
| MQ3 | Monthly seasonality index — highest revenue months | Sophie van Dijk | Two-layer aggregation, AVG OVER(), RANK() | January best (1.11), December worst (0.85) |
| MQ4 | Weekend vs weekday revenue by customer segment | Noor Bakker | FILTER(WHERE), EXTRACT DOW, nested SUM window | Segment mix identical — Consumer always ~52% |
| MQ5 | Summer sale impact (Jun–Aug) vs rest of year on revenue + profit | Sophie van Dijk | GROUP BY CASE, EXTRACT month | Summer -2% revenue per order — not impactful |
| MQ6 | RFM segmentation — Champions/Loyals/At Risk using NTILE(4) | Noor Bakker | NTILE, MAX ref date, CASE, 4-CTE pattern | Champions avg R$2,182 vs Lost R$152 |
| MQ7 | Revenue cohort — revenue in 30 days after first order | Sophie van Dijk | INTERVAL 30 days, MIN first order, repeat flag | Only 4% repeat in 30 days — R$25 incremental |
| MQ8 | A/B test — Corporate vs Consumer segment revenue t-score | Noor Bakker | STDDEV, CROSS JOIN, t-score formula | t=0.99 — not significant, segments behave same |
| MQ9 | Dell product ranking + market share in tech categories | Daan | RANK(), market share %, FIRST_VALUE gap | Dell dominates at 59.37% — Electronics miscategorised |

---

## 🎯 Bonus Marketing Questions (BMQ1–BMQ2) — ✅ Complete

| # | Business Question | Stakeholder | SQL Concepts | Key Finding |
|---|---|---|---|---|
| BMQ1 | Department performance scorecard — NTILE revenue tiers | Sophie van Dijk | NTILE(4), AVG order value, profit ratio | Fan Shop = 46% of all revenue — single point of failure |
| BMQ2 | Hero product analysis — products > 20% of department revenue | Noor Bakker | DENSE_RANK(), PARTITION BY dept, share % flag | Nike Free 5.0+ = 91.31% of Footwear revenue |

---

## 📊 Pivot Practice Questions — ✅ Complete

| # | Business Question | Rows | Columns | Value |
|---|---|---|---|---|
| Pivot 1 | Department monthly revenue heatmap | Department | Month 1–12 | Revenue SUM |
| Pivot 2 | Shipping mode quarterly late rate matrix | Shipping Mode | Quarter 1–4 | Late Rate % |

**Core pivot pattern:**
```sql
SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 1 THEN sales ELSE 0 END) AS jan
COUNT(CASE WHEN EXTRACT(QUARTER FROM order_date) = 1
    AND delivery_status = 'Late delivery' THEN 1 END) AS q1_late
```

---

## 🔗 Sales + Marketing Integrated (SQ1–SQ4) — ✅ All Complete

**Stakeholder:** Carlos (Revenue Analytics) | Emma Clarke + Sophie van Dijk

| # | Business Question | Stakeholder | SQL Concepts | Key Finding |
|---|---|---|---|---|
| SQ1 | 7-day rolling revenue + orders + top 5 revenue spike days | Carlos | ROWS BETWEEN 6 PRECEDING, ORDER BY spike DESC LIMIT 5 | Top spikes Oct 26–29 2017 — data anomaly driven |
| SQ2 | 90-day repeat customer cohort using LEAD() pattern | Carlos | LEAD(), date diff, repeat flag, NULLS LAST | 20.99% repeat rate, avg 43.27 days to return |
| SQ3 | Customer segment x department revenue matrix (pivot) | Emma + Sophie | SUM(CASE WHEN) pivot, GROUP BY segment | Consumer ~51%, Corporate ~31%, HO ~18% — consistent |
| SQ4 | Profit ratio decline month over month by category | Carlos | LAG, MoM %, trend flag, cumulative declining count | Golf Shoes at -0.16 — loss-making, urgent review |

---

## 🏭 DLL Process Mining Questions (DLL Q1–Q5) — 🔜 Pending

**Company:** DLL (De Lage Landen) — Eindhoven, Netherlands | **Role:** Process Mining and Data Analyst

| # | Business Question | SQL Concepts | Status |
|---|---|---|---|
| DLL Q1 | End-to-end process time — bucket into Fast/Normal/Slow/Critical | Throughput time analysis, CASE buckets | 🔜 Pending |
| DLL Q2 | Process deviations — orders where delivery was abnormal by seller state | Deviation from designed flow | 🔜 Pending |
| DLL Q3 | Bottleneck report — avg time per stage, flag sellers > 2x network average | Bottleneck detection, CASE flag | 🔜 Pending |
| DLL Q4 | Monthly process efficiency score per city: (on-time/total) x (avg review/5) | KPI + trend for process improvement | 🔜 Pending |
| DLL Q5 | Root cause — review <= 2, top 5 combinations of seller state + category | Root cause analysis, multi-column GROUP BY | 🔜 Pending |

---

## 🔁 Cohort Analysis Questions — 🔜 Pending

| # | Business Question | Stakeholder | SQL Concepts | Status |
|---|---|---|---|---|
| LQ3b | Pacific Asia monthly SLA breach cohort — worsening over time? | Lars Visser | DATE_TRUNC cohort + LAG trend | 🔜 Pending |
| LQ3c | Customer 90-day repeat cohort — % placing 2nd order in 90 days | Lars Visser | LEAD(), INTERVAL 90 days | 🔜 Pending |
| MQ7b | Monthly revenue cohort retention — months 1, 2, 3 after acquisition | Sophie van Dijk | DATE_TRUNC, INTERVAL, cohort retention | 🔜 Pending |
| MQ7c | Category 30-day repeat rate by customer segment | Noor Bakker | MIN first order, INTERVAL 30 days | 🔜 Pending |

---

## 📊 Tableau Public Dashboard — 🗓️ Planned This Weekend

| # | Dashboard Name | Contents | Status |
|---|---|---|---|
| 1 | Logistics Operations Analytics | Monthly delivery trend, shipping mode scorecard, SLA by market, YoY, rolling signals | 📊 Saturday |
| 2 | Holiday & Seasonality Analytics | Holiday vs regular, weekend vs weekday, seasonality index, NTILE tiers | 📊 Saturday |
| 3 | Marketing & Revenue Analytics | Revenue by department, RFM segments, discount simulation, A/B test | 📊 Sunday |

🔗 Tableau Public Profile: [public.tableau.com/app/profile/sahil.changotra](https://public.tableau.com/app/profile/sahil.changotra)

---

## 🔑 Key Findings Summary

> **Structural Finding across all 12 Logistics Questions:**
> The ~57% late delivery rate is systemic across every dimension — holiday vs regular (+0.73pp), weekend vs weekday (+0.37pp), all customer segments identical, pre/post July 2017 unchanged, seasonality index range only 0.98–1.02. The problem is network infrastructure, not situational.

| Metric | Value | Source |
|---|---|---|
| Overall late delivery rate | ~57% every month — systemic | LQ1 |
| Best shipping mode | Standard Class: -0.01 day gap | LQ2 |
| Worst shipping mode | Second Class: +1.96 day gap, 79.54% late | LQ2 |
| Best market (SLA breach) | Europe: 22.86% breach rate | LQ3 |
| Worst market (SLA breach) | Pacific Asia: 23.92% breach rate | LQ3 |
| First Class anomaly | 100% late delivery — data quality issue | LQ2, LQ8 |
| Holiday season impact | +0.73pp vs regular — not meaningful | LQ6 |
| Weekend vs weekday | +0.37pp — not meaningful | LQ7 |
| Ghost shipments | Second Class only: 38.13% rate | LQ8 |
| NTILE tier change post-Jul 2017 | Fastest tier: 1.67 → 1.70 days | LQ9 |
| Worst seasonality month | August: index 1.02 | LQ12 |
| Fan Shop revenue collapse | -99% from Oct 2017 | MQ1 |
| RFM Champions avg spend | R$2,182 vs Lost R$152 (14x) | MQ6 |
| 30-day repeat rate | Only 4% — 96% one-time buyers | MQ7 |
| 90-day repeat rate | 20.99% — avg 43 days to return | SQ2 |
| Hero product concentration | Nike Free = 91.31% of Footwear | BMQ2 |
| Critical profit issue | Golf Shoes at -0.16 ratio — loss-making | SQ4 |

---

## 🛠️ SQL Concepts Mastered

| Concept | Questions Practised |
|---|---|
| Rolling windows (ROWS BETWEEN) | LQ1, LQ5, SQ1 |
| LAG / LEAD | LQ4, MQ1, SQ2, SQ4 |
| NTILE bucketing | LQ9, MQ2, MQ6, BMQ1 |
| RANK / DENSE_RANK / ROW_NUMBER | LQ2, LQ3, MQ9, BMQ2 |
| UNION ALL period comparison | LQ6, MQ2, MQ5 |
| Pivot (SUM CASE WHEN) | SQ3, Pivot 1, Pivot 2 |
| Window functions + PARTITION BY | LQ10, MQ4, BMQ2 |
| CROSS JOIN t-score | MQ8 |
| RFM segmentation | MQ6 |
| Cohort analysis (INTERVAL + LEAD) | MQ7, SQ2 |
| Two-layer aggregation | LQ12, MQ3 |
| FIRST_VALUE gap analysis | MQ9 |
| Anomaly detection | LQ11 |
| Seasonality index | LQ12, MQ3 |

---

## 👤 About

| Field | Detail |
|---|---|
| Name | Sahil Changotra |
| Location | The Hague, Netherlands |
| GitHub | [github.com/sahilmchangotra](https://github.com/sahilmchangotra) |
| Tableau Public | [public.tableau.com/app/profile/sahil.changotra](https://public.tableau.com/app/profile/sahil.changotra) |
| Target Roles | Data Analyst — JET SODA Amsterdam \| BOL Retail Media Netherlands \| DLL Eindhoven |
| Session | March–April 2026 — Active Portfolio Development |
