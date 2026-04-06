--================================================================================================================
-- INTRODUCING : DLL Process Efficiency
-- ✅ Q4 -   DLL Process Analyst:
-- I need a monthly process efficiency score per market. At DLL we measure efficiency as a composite — combining
-- on-time delivery rate and average review score into a single KPI. The formula is:
-- Efficiency Score = (On-time orders / Total orders) × (1 - avg late delivery risk)
-- This gives a score between 0 and 1 — closer to 1 means perfectly efficient. Then show me the trend — is each market's
-- efficiency improving or declining month over month?
-- For each market and month show me:
--
-- Market
-- Month
-- Total orders
-- On-time rate %
-- Avg review score
-- Efficiency score
-- Previous month efficiency score (LAG)
-- Month over month change
-- Trend flag: Improving / Declining / Stable
--================================================================================================================

WITH process_base AS(
    SELECT
        market,
        DATE_TRUNC('month', order_date) AS month,
        COUNT(order_id) AS total_orders,
        COUNT(order_id) FILTER ( WHERE delivery_status != 'Late delivery' ) AS on_time_orders,
        ROUND(AVG(CASE WHEN delivery_status != 'Late delivery' THEN 1.0 ELSE 0.0 END), 2) AS on_time_rate,
        ROUND((AVG(CASE WHEN delivery_status != 'Late delivery' THEN 1.0 ELSE 0.0 END)) * (1 - AVG(late_delivery_risk)), 4) AS efficiency_score
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY market, DATE_TRUNC('month', order_date)
),
    previous_month_agg AS (
        SELECT
            *,
            LAG(efficiency_score) OVER (
                PARTITION BY market
                ORDER BY month
                ) AS prev_month_eff_score
        FROM process_base
    ),
    month_over_month AS(
        SELECT
            *,
           ROUND((efficiency_score - prev_month_eff_score) * 100.0 / NULLIF(prev_month_eff_score, 0), 4) AS mom_change_pct
        FROM previous_month_agg
    )
SELECT
    market,
    TO_CHAR(month,'YYYY-MM') AS month,
    total_orders,
    on_time_orders,
    on_time_rate,
    efficiency_score,
    prev_month_eff_score,
    mom_change_pct,
    CASE
        WHEN efficiency_score > prev_month_eff_score THEN 'Improving'
        WHEN efficiency_score < prev_month_eff_score THEN 'Declining'
        ELSE 'Stable'
    END AS trend_flag
FROM month_over_month
ORDER BY market, month;