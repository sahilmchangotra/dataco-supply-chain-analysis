# DataCo Smart Supply Chain Analytics

**SQL Analysis Portfolio | Logistics & Marketing Intelligence**

Sahil Changotra • The Hague, Netherlands • March 2026

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

All DataCo queries apply these filters and definitions consistently:

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
│   ├── logistics/       ← LQ1–LQ12 complete ✅
│   ├── marketing/       ← MQ1–MQ9 pending 🔜
│   ├── sales/           ← SQ1–SQ4 pending 🔜
│   ├── cohorts/         ← LQ3b, LQ3c, MQ7b, MQ7c pending 🔜
│   └── dll/             ← DLL Q1–Q5 pending 🔜
├── data/                ← Exported CSVs from DataGrip
├── tableau/             ← Tableau workbook + screenshots (this weekend)
└── README.md
```

---

## 🚚 Logistics SQL Questions (LQ1–LQ12)

**Stakeholders:** Lars Visser (JET SODA Logistics Ops) | Emma Clarke (DataCo Network Planning) | Beatriz Souza (JET SODA Senior Logistics)

| # | Business Question | Stakeholder | SQL Concepts | Status |
|---|---|---|---|---|
| LQ1 | Monthly on-time vs late delivery rate + 3-month rolling avg + alert flag | Lars Visser | Rolling AVG, CASE flag, FILTER(WHERE) | ✅ Done |
| LQ2 | Shipping mode scorecard — real vs scheduled days, delay gap, RANK() | Emma Clarke | AVG, RANK(), gap calc, data_quality_flag | ✅ Done |
| LQ3 | SLA breach rate by market, minimum 1,000 orders, ranked | Lars Visser | INTERVAL breach, HAVING, RANK() | ✅ Done |
| LQ4 | Shipping mode YoY improvement — LAG(12) same month last year | Emma Clarke | LAG(12), PARTITION BY, trend flag | ✅ Done |
| LQ5 | 7-day + 30-day rolling SLA breach daily + worsening flag | Emma Clarke | ROWS BETWEEN, two windows, WHERE >= 5 | ✅ Done |
| LQ6 | Holiday season (Nov 15–Dec 31) vs regular period | Beatriz Souza | GROUP BY CASE, EXTRACT month/day | ✅ Done |
| LQ7 | Weekend vs weekday order volume and late delivery rate | Emma Clarke | EXTRACT DOW, FILTER(WHERE) | ✅ Done |
| LQ8 | Ghost shipments — orders with shipping gap > 5 days by mode | Lars Visser | Date diff, FILTER(WHERE), data_quality_flag | ✅ Done |
| LQ9 | NTILE(4) delivery speed tiers before/after July 2017 | Beatriz Souza | NTILE(4), period flag before NTILE | ✅ Done |
| LQ10 | Late delivery risk % by customer segment trend over time | Emma Clarke | 4-CTE pattern, DATE_TRUNC, LAG trend | ✅ Done |
| LQ11 | Anomaly detection — real days > scheduled + 2 by shipping mode | Lars Visser | FILTER(WHERE), ratio flag, gap detection | ✅ Done |
| LQ12 | Seasonality index — which months have highest late rates | Beatriz Souza | Two-layer aggregation, AVG OVER(), RANK() | ✅ Done |

---

## 📈 Marketing SQL Questions (MQ1–MQ9)

**Stakeholders:** Sophie van Dijk (bol category marketing) | Noor Bakker (bol performance marketing) | Daan (bol product ops)

| # | Business Question | Stakeholder | SQL Concepts | Status |
|---|---|---|---|---|
| MQ1 | Monthly revenue by department + YoY LAG(12) + growth % | Sophie van Dijk | LAG(12), YoY %, DATE_TRUNC | 🔜 Pending |
| MQ2 | Discount simulation — 10% extra on below-avg categories | Noor Bakker | NTILE, UNION ALL, FILTER(WHERE) | 🔜 Pending |
| MQ3 | Monthly seasonality index — highest revenue months | Sophie van Dijk | Two-layer aggregation, index calc | 🔜 Pending |
| MQ4 | Weekend vs weekday revenue by customer segment | Noor Bakker | FILTER(WHERE), EXTRACT DOW | 🔜 Pending |
| MQ5 | Summer sale impact (Jun–Aug) vs rest of year on revenue + profit | Sophie van Dijk | CASE period, UNION ALL | 🔜 Pending |
| MQ6 | RFM segmentation — Champions/Loyals/At Risk using NTILE(4) | Noor Bakker | NTILE, MAX ref date, CASE | 🔜 Pending |
| MQ7 | Revenue cohort — revenue in 30 days after first order | Sophie van Dijk | INTERVAL 30 days, LEAD() | 🔜 Pending |
| MQ8 | A/B test — Corporate vs Consumer segment revenue t-score | Noor Bakker | STDDEV, CROSS JOIN, t-score formula | 🔜 Pending |
| MQ9 | Samsung scenario — Technology category product ranking + market share | Daan | RANK(), market share %, window | 🔜 Pending |

---

## 🔗 Sales + Marketing Integrated (SQ1–SQ4)

**Stakeholder:** Carlos (Revenue Analytics) | Emma Clarke + Sophie van Dijk

| # | Business Question | Stakeholder | SQL Concepts | Status |
|---|---|---|---|---|
| SQ1 | 7-day rolling revenue + orders + top 5 revenue spike days | Carlos | ROWS BETWEEN 6 PRECEDING, RANK() | 🔜 Pending |
| SQ2 | INTERVAL 90 days — same customer repeat flag + 90-day repeat revenue | Carlos | INTERVAL 90, LAG pattern | 🔜 Pending |
| SQ3 | Customer segment x department revenue matrix | Emma + Sophie | CROSS JOIN, pivot-style | 🔜 Pending |
| SQ4 | Profit ratio decline month over month by category | Carlos | LAG, month-over-month, trend flag | 🔜 Pending |

---

## 🔁 Cohort Analysis Questions

| # | Business Question | Stakeholder | SQL Concepts | Status |
|---|---|---|---|---|
| LQ3b | Pacific Asia monthly SLA breach cohort — worsening over time? | Lars Visser | DATE_TRUNC cohort + LAG trend | 🔜 Pending |
| LQ3c | Customer 90-day repeat cohort — % placing 2nd order in 90 days | Lars Visser | LEAD(), INTERVAL 90 days | 🔜 Pending |
| MQ7b | Monthly revenue cohort retention — months 1, 2, 3 after acquisition | Sophie van Dijk | DATE_TRUNC, INTERVAL, cohort retention | 🔜 Pending |
| MQ7c | Category 30-day repeat rate by customer segment | Noor Bakker | MIN first order, INTERVAL 30 days | 🔜 Pending |

---

## 🏭 DLL Process Mining Questions (DLL Q1–Q5)

**Company:** DLL (De Lage Landen) — Eindhoven, Netherlands | **Role:** Process Mining and Data Analyst

| # | Business Question | SQL Concepts | Status |
|---|---|---|---|
| DLL Q1 | End-to-end process time — bucket into Fast/Normal/Slow/Critical | Throughput time analysis, CASE buckets | 🔜 Pending |
| DLL Q2 | Process deviations — orders where delivery was abnormal by seller state | Deviation from designed flow | 🔜 Pending |
| DLL Q3 | Bottleneck report — avg time per stage, flag sellers > 2x network average | Bottleneck detection, CASE flag | 🔜 Pending |
| DLL Q4 | Monthly process efficiency score per city: (on-time/total) x (avg review/5) | KPI + trend for process improvement | 🔜 Pending |
| DLL Q5 | Root cause — review <= 2, top 5 combinations of seller state + category | Root cause analysis, multi-column GROUP BY | 🔜 Pending |

---

## 📊 Tableau Public Dashboard

> 🗓️ **Planned for this Saturday / Sunday**

| # | Dashboard Name | Contents | Status |
|---|---|---|---|
| 1 | Logistics Operations Analytics | Monthly delivery trend, shipping mode scorecard, SLA by market, YoY, rolling signals | 📊 Saturday |
| 2 | Holiday & Seasonality Analytics | Holiday vs regular, weekend vs weekday, seasonality index, NTILE tiers | 📊 Saturday |
| 3 | Marketing & Revenue Analytics | Revenue by department, RFM segments, discount simulation, A/B test | 📊 Sunday |

🔗 Tableau Public Profile: [public.tableau.com/app/profile/sahil.changotra](https://public.tableau.com/app/profile/sahil.changotra)

---

## 🔑 Key Findings Summary

> **Structural Finding across all 12 Logistics Questions:**
> The ~57% late delivery rate is systemic and consistent across every dimension analysed — holiday vs regular (+0.73pp), weekend vs weekday (+0.37pp), all customer segments identical, pre/post July 2017 NTILE tiers unchanged, and seasonality index range only 0.98–1.02. The problem is network infrastructure, not situational factors.

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
| Ghost shipments | Second Class only: 38.13% rate, +3.51 day gap | LQ8 |
| NTILE tier change post-Jul 2017 | Fastest tier: 1.67 → 1.70 days (no improvement) | LQ9 |
| Worst seasonality month | August: index 1.0226 (2.3% above avg) | LQ12 |
| Best seasonality month | January: index 0.9765 (2.4% below avg) | LQ12 |

---

## 👤 About

| Field | Detail |
|---|---|
| Name | Sahil Changotra |
| Location | The Hague, Netherlands |
| GitHub | [github.com/sahilmchangotra](https://github.com/sahilmchangotra) |
| Tableau Public | [public.tableau.com/app/profile/sahil.changotra](https://public.tableau.com/app/profile/sahil.changotra) |
| Target Roles | Data Analyst — JET SODA Amsterdam \| BOL Retail Media Netherlands \| DLL Eindhoven |
| Session | March 2026 — Active Portfolio Development |