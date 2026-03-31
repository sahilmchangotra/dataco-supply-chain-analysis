--==========================================================================================
-- INTRODUCING : LOGISTICS Practice SQL
-- ✅ Q5 -  DataCo Network Planning:
-- "The monthly view is good for board reporting but I need something more operational —
-- a daily early warning signal.
-- I want a daily SLA breach monitoring report. For each day show me:
--
-- Total orders delivered that day
-- Number of SLA breached orders
-- Daily breach rate %
-- 7-day rolling average breach rate
-- 30-day rolling average breach rate
-- A worsening signal flag — if the 7-day average is HIGHER than the 30-day average, that means things
-- are getting worse recently. Flag it as 'Worsening' otherwise 'Stable or Improving'
--
-- This is my early warning dashboard — I check it every morning to catch deteriorating performance before
-- it becomes a crisis.
-- Only include days with at least 5 orders so we don't get noise from low-volume days."
--==========================================================================================

-- One row in my base CTE = one DATE_TRUNC('day',order_date)

WITH order_delivery AS (
    SELECT
        DATE_TRUNC('day',order_date) AS order_day,
        COUNT(order_id) AS total_orders,
        SUM(CASE
                WHEN days_for_shipping_real > days_for_shipment_scheduled + 1 THEN 1
                ELSE 0 END) AS total_sla_breach_orders,
        ROUND(SUM(CASE
                WHEN days_for_shipping_real > days_for_shipment_scheduled + 1 THEN 1
                ELSE 0 END) * 100.0 /
        NULLIF(COUNT(order_id),0)::NUMERIC, 2) AS daily_breach_rate_pct
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY DATE_TRUNC('day',order_date)
),
    rolling_avg AS(
        SELECT
            *,
            ROUND(AVG(daily_breach_rate_pct) OVER (
                ORDER BY order_day
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
                )::NUMERIC, 2) AS avg_rolling_7d_breach_rate,
            ROUND(AVG(daily_breach_rate_pct) OVER (
                ORDER BY order_day
                ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
                )::NUMERIC, 2) AS avg_rolling_30d_breach_rate
        FROM order_delivery
    ),
    signal_flag AS(
        SELECT
            *,
            CASE
                WHEN avg_rolling_7d_breach_rate > avg_rolling_30d_breach_rate
                    THEN 'Worsening'
                ELSE 'Stable or Improving'
            END AS flag
        FROM rolling_avg
    )
SELECT
    DATE(order_day) AS day,
    To_CHAR(order_day, 'YYYY-MM') AS year_month,
    total_orders,
    total_sla_breach_orders,
    daily_breach_rate_pct,
    avg_rolling_7d_breach_rate,
    avg_rolling_30d_breach_rate,
    flag
FROM signal_flag
WHERE total_orders >= 5
ORDER BY day;