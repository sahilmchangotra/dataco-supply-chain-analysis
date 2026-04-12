# DataCo Smart Supply Chain Analytics
**SQL Analysis Portfolio | 42 Core + 25 Advanced Questions | Logistics · Marketing · Sales · Process Mining · Interview Prep**

Sahil Changotra • The Hague, Netherlands • April 2026

---

## 📋 Project Overview

| Field | Detail |
|---|---|
| Dataset | DataCo Smart Supply Chain — Kaggle |
| Database | dataco_db — Schema: supply_chain — Table: supply_chain.orders |
| Rows | 180,519 orders — Date Range: 2015-01-01 to 2018-01-31 |
| Markets | Africa, Europe, LATAM, Pacific Asia, USCA |
| Segments | Consumer, Corporate, Home Office |
| Shipping Modes | First Class, Same Day, Second Class, Standard Class |
| Target Roles | Data Analyst — JET SODA Amsterdam \| BOL Retail Media Netherlands \| DLL Eindhoven |
| Stack | PostgreSQL / DataGrip • Python (Jupyter) • Tableau Public • GitHub |
| Total Questions | 67 SQL questions across 8 analytical blocks |

> ⚠️ **Critical Data Quality Issue — First Class Shipping**
> First Class shipping mode has 100% late delivery rate with zero on-time records across all markets and all time periods. This is a known DataCo dataset anomaly flagged in every relevant query with a `data_quality_flag` column.

> 📉 **Volume Collapse — October 2017 Onwards**
> Daily order volume drops from ~70–100 orders/day to ~25–40 orders/day from October 2017. Revenue collapses by over 60% in affected months. Results from this period are treated as unreliable and flagged throughout.

---

## 🔧 Standard Query Rules

| Rule | Definition |
|---|---|
| Standard Filter | `WHERE order_status IN ('COMPLETE', 'CLOSED') AND delivery_status != 'Shipping canceled'` |
| Count Rule | Always `COUNT(DISTINCT order_id)` — multiple line items per order |
| SLA Breach | `days_for_shipping_real > days_for_shipment_scheduled + 1` |
| Late Delivery | `delivery_status = 'Late delivery'` |
| Date Grouping | Always `DATE_TRUNC('month', order_date)` — never `EXTRACT(MONTH)` alone |
| Schema Prefix | Always `supply_chain.orders` — never just `orders` |
| First Class Flag | Always add `data_quality_flag` — 100% late delivery anomaly |

---

## 📁 Repository Structure

```
dataco-supply-chain-analysis/
├── sql/
│   ├── logistics/            ← LQ1–LQ12  ✅ Complete
│   ├── marketing/            ← MQ1–MQ9 + BMQ1–BMQ2  ✅ Complete
│   ├── sales/                ← SQ1–SQ4  ✅ Complete
│   ├── cohorts/              ← LQ3b, LQ3c, MQ7b, MQ7c  ✅ Complete
│   ├── dll/                  ← DLL Q1–Q5  ✅ Complete
│   ├── interview_questions/  ← IQ1–IQ15  ✅ Complete
│   └── mixed_practice/       ← MX1–MX10  ✅ Complete
├── data/
├── tableau/
└── README.md
```

---

## 🚚 LOGISTICS (LQ1–LQ12) — ✅ All Complete

**Stakeholders:** Lars Visser — JET SODA Logistics Ops | Emma Clarke — DataCo Network Planning | Beatriz Souza — JET SODA Senior Logistics

| # | Business Question | Key Concepts | Key Finding |
|---|---|---|---|
| LQ1 | Monthly on-time vs late + 3-month rolling avg + alert flag | Rolling AVG, CASE flag, FILTER(WHERE) | Every single month triggers the alert flag — late rate never drops below 52% in any month across the entire 3-year dataset |
| LQ2 | Shipping mode scorecard — real vs scheduled days + RANK() | AVG, RANK(), delay gap calc | Second Class worst at +1.96 day gap and 79.54% late rate. Standard Class best at -0.01 day gap. First Class flagged as data anomaly |
| LQ3 | SLA breach rate by market, min 1,000 orders, ranked | INTERVAL breach, HAVING, RANK() | Pacific Asia worst at 23.92% SLA breach. Europe best at 22.86%. Difference is only 1.06pp — breach is systemic across ALL markets |
| LQ4 | Shipping mode YoY improvement — LAG(12) same month last year | LAG(12), PARTITION BY, trend flag | Standard Class is the ONLY shipping mode showing improvement in H2 2017. All other modes stagnant or worsening |
| LQ5 | 7-day + 30-day rolling SLA breach + worsening flag | ROWS BETWEEN, dual rolling windows | First worsening flag triggered January 17 2015 — just 17 days into the dataset. Worsening periods cluster in Aug–Oct of every year |
| LQ6 | Holiday season (Nov 15–Dec 31) vs regular period | GROUP BY CASE, EXTRACT month/day | Holiday season late rate only +0.73pp worse than regular. The network performs equally badly year-round — no seasonal deterioration |
| LQ7 | Weekend vs weekday order volume and late delivery rate | EXTRACT DOW, FILTER(WHERE) | Weekend late rate only +0.37pp higher than weekday. Staffing levels have no meaningful impact on delivery performance |
| LQ8 | Ghost shipments — orders with shipping gap > 5 days by mode | Date diff, FILTER(WHERE) | Ghost shipments exist ONLY in Second Class — 38.13% ghost rate. All other modes: 0%. Second Class has a systematic dispatch delay problem |
| LQ9 | NTILE(4) speed tiers before/after July 2017 | NTILE(4), period flag | Fastest tier delivery time: 1.67 days → 1.70 days after July 2017. Despite network changes, fastest deliveries actually got SLOWER |
| LQ10 | Late delivery risk by customer segment trend | 4-CTE pattern, DATE_TRUNC, LAG | Consumer, Corporate and Home Office all show ~57% late rate. Segment has ZERO predictive power for delivery risk |
| LQ11 | Anomaly detection — real days > scheduled + 2 | FILTER(WHERE), ratio flag | Second Class: 38.13% of orders take more than 2x scheduled time. Same Day: 0%. Standard Class: 0%. Second Class is structurally broken |
| LQ12 | Seasonality index — worst/best months for late delivery | Two-layer aggregation, AVG OVER(), RANK() | August is worst month (index 1.0226). January is best (0.9815). But the range is only 4pp — confirming the problem is structural not seasonal |

### 🔑 Logistics Headline Finding
> **The ~57% late delivery rate is completely systemic.** It does not vary meaningfully by shipping mode (excluding anomalies), market, customer segment, season, or day of week. The root cause is network infrastructure — not operational decisions. Second Class shipping is the only mode with a distinct and severe structural problem: 38.13% ghost shipment rate, 79.54% late rate, and 38.13% of orders taking more than 2x their scheduled time.

---

## 📈 MARKETING (MQ1–MQ9 + BMQ1–BMQ2) — ✅ All Complete

**Stakeholders:** Sophie van Dijk — BOL Category Marketing | Noor Bakker — BOL Performance Marketing | Daan — BOL Product Ops

| # | Business Question | Key Concepts | Key Finding |
|---|---|---|---|
| MQ1 | Monthly revenue by dept + YoY LAG(12) + growth % | LAG(12), YoY %, DATE_TRUNC | Fan Shop generates 46% of all revenue but collapsed -99% from October 2017 — a catastrophic single-category dependency |
| MQ2 | Discount simulation — 10% extra on below-avg categories | NTILE, UNION ALL, simulation | 41 out of 49 product categories are below average revenue. A 10% discount push on these would add ~20% incremental revenue |
| MQ3 | Monthly seasonality index — revenue peaks | Two-layer aggregation, index calc | January is the strongest revenue month (index 1.11). December is the weakest (0.85) — counter-intuitive given typical retail patterns |
| MQ4 | Weekend vs weekday revenue by customer segment | FILTER(WHERE), EXTRACT DOW | Consumer segment is always ~52% of revenue on both weekdays and weekends. Corporate never exceeds 32%. Segment mix is completely stable |
| MQ5 | Summer sale impact (Jun–Aug) vs rest of year | CASE period, UNION ALL | Summer months generate 2% less revenue per order than the rest of the year. Summer sale has no meaningful positive impact |
| MQ6 | RFM segmentation — Champions/Loyals/At Risk/Lost | NTILE(4), MAX ref date, CASE | Champions avg spend: €2,182 vs Lost customers: €152 — a 14x difference. At Risk segment is 25% of customers and needs immediate intervention |
| MQ7 | Revenue cohort — 30-day revenue after first order | INTERVAL 30 days, LEAD() | Only 4% of customers place a second order within 30 days. 96% are effectively one-time buyers in their first month |
| MQ8 | A/B test — Corporate vs Consumer revenue t-score | STDDEV, CROSS JOIN, t-score | T-score = 0.99 (threshold: 1.96). Corporate and Consumer segments are statistically IDENTICAL in spend behaviour. Separate campaigns are not justified by data |
| MQ9 | Samsung/Technology product ranking + market share | RANK(), market share %, window | Top technology product holds 59.37% market share within its category. The category has extreme concentration risk |
| BMQ1 | Department performance scorecard — NTILE tiers | NTILE(4), profit ratio | Fan Shop alone = 46% of total revenue. If Fan Shop fails, the entire business model collapses. Extreme single-category dependency |
| BMQ2 | Hero product — products >20% of department revenue | DENSE_RANK(), share % flag | Nike Free 5.0+ = 91.31% of all Footwear revenue. A single SKU discontinuation would effectively kill the entire Footwear department |

### 🔑 Marketing Headline Finding
> **The business has dangerous concentration risk at every level.** Fan Shop = 46% of revenue (department level). Nike Free = 91% of Footwear (product level). January = strongest month (11% above avg). And 96% of customers never return within 30 days. The RFM analysis reveals Champions spend 14x more than Lost customers — yet the A/B test proves Corporate and Consumer behave identically, meaning segmentation campaigns need to focus on RFM behaviour, not company type.

---

## 💼 SALES INTEGRATED (SQ1–SQ4) — ✅ All Complete

**Stakeholders:** Carlos — Revenue Analytics | Emma Clarke + Sophie van Dijk

| # | Business Question | Key Concepts | Key Finding |
|---|---|---|---|
| SQ1 | 7-day rolling revenue + top 5 spike days | ROWS BETWEEN 6 PRECEDING, RANK() | Top revenue spikes all cluster in Oct 26–29 2017 — coinciding with the dataset anomaly. Largest legitimate spike: Jan 25 2015 at 49% above rolling average |
| SQ2 | 90-day repeat customer cohort | LEAD(), INTERVAL 90 days | 20.99% of customers place a second order within 90 days. Average time to return: 43.27 days. This is the key retention window for campaigns |
| SQ3 | Customer segment × department revenue matrix | SUM(CASE WHEN) pivot, GROUP BY | Consumer ~51%, Corporate ~31%, Home Office ~18% across ALL departments. No department shows a significantly different segment mix |
| SQ4 | Profit ratio decline MoM by category | LAG, MoM %, trend flag | Golf Shoes at -0.16 profit ratio — actively loss-making. 3 categories have negative profit ratios and require immediate pricing review |

---

## 🔁 COHORT ANALYSIS (LQ3b, LQ3c, MQ7b, MQ7c) — ✅ All Complete

| # | Business Question | Key Concepts | Key Finding |
|---|---|---|---|
| LQ3b | Pacific Asia monthly SLA breach cohort | DATE_TRUNC cohort + LAG trend | Pacific Asia SLA breach rate worsened consistently from Q3 2016, accelerating into Q4 2017 — the market most affected by the Oct 2017 collapse |
| LQ3c | Customer 90-day repeat cohort | LEAD(), INTERVAL 90 days | 20.99% repeat rate. Customers acquired in Jan–Mar 2015 have the highest retention — earliest cohorts are the most loyal |
| MQ7b | Monthly revenue cohort retention months 1–3 | DATE_TRUNC, INTERVAL, retention | Month 1 retention: 4%. Month 2: drops further. Month 3: near zero. The vast majority of revenue is single-transaction |
| MQ7c | Category 30-day repeat rate by segment | MIN first order, INTERVAL 30 days | Technology has the highest 30-day repeat rate. Pet Shop and Book Shop have near-zero repeat rates — likely one-time gift purchases |

---

## 🏭 DLL PROCESS MINING (DLL Q1–Q5) — ✅ All Complete

**Company:** DLL (De Lage Landen) — Eindhoven, Netherlands | Process Mining & Data Analyst role

| # | Business Question | Key Concepts | Key Finding |
|---|---|---|---|
| DLL Q1 | End-to-end process time — Fast/Normal/Slow/Critical buckets | Throughput time, CASE buckets | 23% of all orders fall in Critical bucket (>7 days). Only 18% are Fast (<3 days). The process is skewed toward slow delivery |
| DLL Q2 | Process deviations — abnormal delivery by seller state | Deviation detection, ratio | Certain seller states show 3x the deviation rate of the network average — geographic bottlenecks in the supply chain |
| DLL Q3 | Bottleneck report — avg time per stage, flag >2x network avg | Bottleneck detection, CASE flag | Preparation-to-dispatch stage is the primary bottleneck — flagged in 31% of seller-state combinations |
| DLL Q4 | Monthly process efficiency score | KPI formula, trend | Efficiency score peaked in early 2016 at 0.43 and has declined to 0.31 by mid-2017 — a 28% efficiency degradation |
| DLL Q5 | Root cause — review ≤2, top 5 seller state + category combos | Root cause, multi-column GROUP BY | Top 5 worst seller-category combinations account for 34% of all low-review orders — highly concentrated failure points |

---

## 🎯 INTERVIEW QUESTIONS (IQ1–IQ15) — ✅ All Complete

| # | Company | Question | Key Concept | Key Finding |
|---|---|---|---|---|
| IQ1 | Flipkart | Daily active customers + 7-day rolling avg | Rolling AVG | Peak daily active customers: 40 (Jan 26 2015). Rolling avg stabilises at ~32-35 through 2016 before Oct 2017 collapse |
| IQ2 | Amazon | Consecutive month orders — longest streak | Gaps-and-islands, ROW_NUMBER | Longest consecutive ordering streak: 6 months (customers 8314 and 12242). Most customers show irregular patterns |
| IQ3 | Zomato | Peak month per department DENSE_RANK | DENSE_RANK, PARTITION BY | Fan Shop peak: May 2017 with 567 orders. Technology peak: October 2017 with 434 — then both collapse the following month |
| IQ4 | Uber | Power seller flag — OLIST dataset | FILTER(WHERE), ratio | 450 power sellers identified (>2 orders/day average). Power sellers generate 3x revenue of regular sellers |
| IQ5 | Swiggy | Top 3 products per city DENSE_RANK | DENSE_RANK, PARTITION BY city | Perfect Fitness Perfect Rip Deck dominates globally — appears in top 3 across 47 different cities |
| IQ6 | Delhivery | On-time % per route MoM + trend flag | LAG, trend flag | All routes to Caguas (Puerto Rico) show 0% on-time delivery across every single month — a systemic destination failure |
| IQ7 | Flipkart | 7 consecutive login/order days | Gaps-and-islands | Zero customers placed orders on 7 consecutive calendar days — the loyalty streak threshold is too aggressive for this market |
| IQ8 | Amazon | Products dropped from top 10 revenue | Two-period JOIN, DENSE_RANK | Only 1 product dropped from top 10 between 2016–2017: Adidas Youth Germany Kit — a 66% revenue drop tied to post-Euro 2016 fading demand |
| IQ9 | Meesho | Seller GMV rank per category — OLIST | DENSE_RANK PARTITION BY category | Ibitinga dominates home/furniture categories. Guariba leads watches (€198,822). City-level concentration is extreme |
| IQ10 | Nykaa | MoM buyer retention cohort — OLIST | Cohort + LEFT JOIN INTERVAL | Month-on-month retention averages 5-6%. Peaks at 10.37% in March 2017. Sep 2017 onwards shows 0% — data quality cutoff |
| IQ11 | BigBasket | Second highest order value per customer | DENSE_RANK = 2 | Top second-highest order: Customer 3758 at €1,694.93. Customers with 10 total orders still show high second-best values — consistent high spenders |
| IQ12 | DHL/FedEx | Delayed shipments >2x expected transit | FILTER(WHERE) + ratio | Same Day mode has 48.51% of orders taking >2x their promised time — the premium service is the LEAST reliable |
| IQ13 | Uber Eats | Running total reset monthly | SUM() OVER PARTITION BY month | Monthly running totals reveal September 2017 peak at €529,714 — the last healthy month before the Oct 2017 collapse |
| IQ14 | Ola | Peak hour per city | EXTRACT(HOUR), DENSE_RANK | New York City peaks at 10pm with 25 orders. Chicago at 3am with 14. Peak hours vary dramatically by city — no universal pattern |
| IQ15 | Flipkart | Median without PERCENTILE_CONT | FLOOR/CEIL + ROW_NUMBER trick | Median order values: Consumer €499.95, Corporate €509.96, Home Office €499.94 — nearly identical medians confirm segments are behaviourally homogeneous |

---

## 🔀 MIXED PRACTICE (MX1–MX10) — ✅ All Complete

| # | Business Question | Key Concepts | Key Finding |
|---|---|---|---|
| MX1 | Top 3 worst delivery days per market | DENSE_RANK, PARTITION BY market | Pacific Asia Nov 17 2016 = 90% late rate — single worst delivery day in entire dataset. Africa and USCA also peak in Nov 2016 |
| MX2 | Product profit rank per dept — Hero/Retire flags | ROW_NUMBER, profit ratio | 3 products have negative profit ratios: SOLE E35 Elliptical, Diamondback Girls' Bike, Cleveland Golf Women's Set — all require immediate pricing action |
| MX3 | Worst month per shipping mode + market | PARTITION BY 2 columns, DENSE_RANK | Second Class Pacific Asia October 2016 = 70.49% SLA breach rate — the single worst mode-market-month combination in the dataset |
| MX4 | Daily customers 7-day rolling + spike days | ROWS BETWEEN, RANK() | Most anomalous spike: Jan 25 2015 — 38 customers vs 25.43 rolling avg (49% above normal). Spikes are random, not seasonal |
| MX5 | Top customer per segment + department | DENSE_RANK, PARTITION BY 2 columns | Fan Shop VIP: Home Office customer 2537 at €3,949.72. Fan Shop produces highest VIPs across ALL three segments |
| MX6 | Rank months by delay gap per market + mode | PARTITION BY 2 columns, DENSE_RANK | Europe Second Class August 2016 = 3.00 days average delay gap — worst in entire dataset. All 5 markets agree: Second Class is the problem |
| MX7 | Top 3 city pairs by late rate | Route concatenation, global DENSE_RANK | All 3 worst routes end in Caguas, Puerto Rico: Edinburgh→Caguas 87.5%, Hamburg→Caguas 84.38%, Stockholm→Caguas 80.49%. Caguas is a delivery black hole |
| MX8 | Pivot orders by shipping mode × quarter | FILTER(WHERE EXTRACT QUARTER) | Q1 and Q4 consistently strongest across all modes. Q2 weakest. Standard Class = 60% of all orders. Same Day = only 5% of volume |
| MX9 | Rank orders by value + peak spender flag | FIRST_VALUE, DENSE_RANK | Majority of customers show most recent order = highest order — spending is growing. Declining customers (best order in past) are identifiable for win-back campaigns |
| MX10 | Daily active customers per market 30-day rolling | ROWS BETWEEN 29 PRECEDING, PARTITION BY market | Europe is strongest and most stable at 30+ rolling avg by Nov 2017. USCA collapses Aug 2016 and never recovers — may indicate data collection failure not real churn |

---

## 🏆 MASTER FINDINGS SUMMARY

### Logistics
| Metric | Value | Source |
|---|---|---|
| Overall late delivery rate | ~57% — systemic across ALL dimensions | LQ1 |
| First Class late rate | 100% — data quality anomaly | LQ2 |
| Second Class late rate | 79.54% — worst real performer | LQ2 |
| Second Class ghost shipment rate | 38.13% — only mode affected | LQ8 |
| Second Class 2x breach rate | 38.13% — structurally broken | LQ11 |
| Second Class avg delay gap | +1.96 days above schedule | LQ2 |
| Worst mode-market-month | Second Class × Pacific Asia × Oct 2016: 70.49% SLA breach | MX3 |
| Holiday season impact | +0.73pp vs regular — not meaningful | LQ6 |
| Weekend vs weekday impact | +0.37pp — not meaningful | LQ7 |
| Segment impact | Zero — all segments identical at ~57% | LQ10 |
| Worst seasonal month | August (index 1.0226) | LQ12 |
| Worst single delivery day | Pacific Asia Nov 17 2016 — 90% late | MX1 |
| Worst city pair | Edinburgh → Caguas: 87.5% late | MX7 |
| Same Day 2x breach rate | 48.51% — premium mode is least reliable | IQ12 |
| Process efficiency decline | 0.43 → 0.31 (28% degradation 2016–2017) | DLL Q4 |

### Marketing & Revenue
| Metric | Value | Source |
|---|---|---|
| Fan Shop revenue share | 46% of all revenue | BMQ1 |
| Fan Shop Oct 2017 collapse | -99% revenue drop | MQ1 |
| Nike Free revenue concentration | 91.31% of all Footwear revenue | BMQ2 |
| 30-day repeat rate | Only 4% of customers | MQ7 |
| 90-day repeat rate | 20.99% — avg 43.27 days to return | SQ2 |
| RFM Champions vs Lost spend | €2,182 vs €152 — 14x difference | MQ6 |
| Corporate vs Consumer t-score | 0.99 — NOT statistically different | MQ8 |
| Median order value (all segments) | ~€499–510 — segments are homogeneous | IQ15 |
| Below-avg revenue categories | 41 out of 49 departments | MQ2 |
| Summer sale impact | -2% revenue per order — negative impact | MQ5 |
| January vs December revenue index | 1.11 vs 0.85 — 30% swing | MQ3 |
| Loss-making products | 3 confirmed: SOLE E35, Diamondback, Cleveland Golf | MX2 |

### Customer & Interview Insights
| Metric | Value | Source |
|---|---|---|
| Longest ordering streak | 6 consecutive months (customers 8314, 12242) | IQ2 |
| 7-day consecutive order streak | 0 customers — threshold too aggressive | IQ7 |
| Products dropped top 10 (2016→2017) | 1 product — Adidas Germany Kit (-66%) | IQ8 |
| Peak city daily orders | New York City: 25 orders at 10pm | IQ14 |
| Best monthly retention (OLIST) | 10.37% — March 2017 | IQ10 |
| Most loyal cohort | Jan–Mar 2015 first buyers | LQ3c |

---

## 🛠️ SQL CONCEPTS MASTERED

| Concept | Questions Practised |
|---|---|
| Rolling windows (ROWS BETWEEN N PRECEDING) | LQ1, LQ5, SQ1, MX4, MX10 |
| LAG / LEAD — trend detection | LQ4, MQ1, SQ2, SQ4, IQ6, IQ10 |
| NTILE bucketing | LQ9, MQ2, MQ6, BMQ1 |
| RANK / DENSE_RANK / ROW_NUMBER | LQ2, LQ3, MQ9, BMQ2, IQ3, IQ5, MX1–MX7 |
| FILTER(WHERE) aggregation | Throughout |
| UNION ALL period comparison | LQ6, MQ2, MQ5 |
| Pivot — SUM(CASE WHEN) / FILTER(WHERE EXTRACT) | SQ3, MX8 |
| PARTITION BY 2 columns | MX3, MX5, MX6 |
| CROSS JOIN for t-score calculation | MQ8 |
| RFM segmentation with NTILE | MQ6 |
| Cohort analysis — INTERVAL + LEAD | MQ7, SQ2, LQ3c, IQ10 |
| Two-layer aggregation for index | LQ12, MQ3 |
| FIRST_VALUE comparison | MX9 |
| Anomaly and outlier detection | LQ11, IQ12 |
| Gaps-and-islands — ROW_NUMBER minus date | IQ2, IQ7 |
| Two-period JOIN for year-over-year | MQ1, IQ8 |
| Median without PERCENTILE_CONT | IQ15 |
| Running total with monthly reset | IQ13 |
| Route concatenation for pair analysis | MX7 |
| FLOOR / CEIL for median position | IQ15 |
| SUM(SUM(col)) OVER() grand total pattern | MQ4 |
| EXTRACT(HOUR) for peak time analysis | IQ14 |

---

## 👤 About

| Field | Detail |
|---|---|
| Name | Sahil Changotra |
| Location | The Hague, Netherlands |
| GitHub | [github.com/sahilmchangotra](https://github.com/sahilmchangotra) |
| Tableau Public | [public.tableau.com/app/profile/sahil.changotra](https://public.tableau.com/app/profile/sahil.changotra) |
| Certification | Google Data Analytics Certificate |
| Target Roles | Data Analyst — JET SODA Amsterdam \| BOL Retail Media Netherlands \| DLL Eindhoven |
| Sessions | March 30 – April 12, 2026 — 67 SQL questions across 8 analytical blocks |