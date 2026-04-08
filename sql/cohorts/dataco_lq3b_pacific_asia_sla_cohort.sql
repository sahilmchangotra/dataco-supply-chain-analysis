--================================================================================================================
-- INTRODUCING : Cohort Questions
-- ✅ Q1 -   JET SODA Logistics Ops:
-- I want to understand Pacific Asia's SLA breach trend over time — not just a snapshot. I need a monthly
-- cohort showing breach rate per month and whether it's getting worse over time compared to the previous month.
-- For Pacific Asia only, show me:
--
-- Month
-- Total orders
-- SLA breached orders
-- SLA breach rate %
-- Previous month breach rate (LAG)
-- Month over month change %
-- Trend flag: Worsening / Improving / Stable
-- 3-month rolling avg breach rate
--================================================================================================================

WITH order_agg AS(
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT order_id) FILTER (WHERE days_for_shipping_real > days_for_shipment_scheduled + 1) AS sla_breached_orders,
        ROUND(COUNT(DISTINCT order_id) FILTER (WHERE days_for_shipping_real > days_for_shipment_scheduled + 1) * 100.0 /
                NULLIF(COUNT(DISTINCT order_id),0), 2) AS sla_breach_rate_pct
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
        AND market = 'Pacific Asia'
    GROUP BY DATE_TRUNC('month', order_date)
),
    previous_month AS(
        SELECT
            *,
            LAG(sla_breach_rate_pct) OVER (
                ORDER BY month
                ) AS last_month_breach_rate
        FROM order_agg
    ),
    month_change AS(
        SELECT
            *,
            ROUND((sla_breach_rate_pct - last_month_breach_rate) * 100.0 /
                    NULLIF(last_month_breach_rate,0), 2) AS mom_change_pct,
            CASE
                WHEN sla_breach_rate_pct > last_month_breach_rate THEN 'Worsening'
                WHEN sla_breach_rate_pct < last_month_breach_rate THEN 'Improving'
                ELSE 'Stable'
            END AS trend_flag
        FROM previous_month
    )
SELECT
    TO_CHAR(month, 'YYYY-MM') AS month,
    total_orders,
    sla_breached_orders,
    sla_breach_rate_pct,
    last_month_breach_rate,
    mom_change_pct,
    ROUND(AVG(sla_breach_rate_pct) OVER (
                ORDER BY month
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
                ), 2) AS rolling_3m_avg,
    trend_flag
FROM month_change
ORDER BY month;