--===============================================================================================================
-- INTRODUCING : JET SODA Senior Logistics
-- ✅ Q11 - JET SODA Courier Operations:
-- "I need to understand seasonality in our delivery performance. My hypothesis is that certain months are structurally
-- worse for late deliveries — not just random noise but a repeatable pattern year over year.
-- Calculate a seasonality index for each month. The index should show whether that month performs above or below the
-- overall average. An index above 1.0 means that month is worse than average, below 1.0 means better.
-- For each month show me:
--
-- Month number (1-12)
-- Month name
-- Total orders across all years
-- Total late deliveries
-- Avg late rate % for that month across all years
-- Overall avg late rate % across all months
-- Seasonality index (month avg / overall avg)
-- Rank by index descending — worst month first
--
-- Same filters as always."
--===============================================================================================================

-- One row in my base CTE = one order

WITH order_base AS(
    SELECT
        EXTRACT(MONTH FROM order_date)::INT AS month_num,
        COUNT(order_id) AS total_orders,
        SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS total_late_deliveries,
        ROUND(SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 /
                NULLIF(COUNT(order_id),0)::NUMERIC, 2) AS late_rate_pct
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY EXTRACT(MONTH FROM order_date)::INT
),
    overall_avg AS(
        SELECT
            *,
            TO_CHAR(TO_DATE(month_num::TEXT, 'MM'), 'Month') AS month_name,
            AVG(late_rate_pct) OVER () AS overall_avg_late_rate
        FROM order_base
    ),
    seasonality AS (
        SELECT
            *,
            ROUND(late_rate_pct / NULLIF(overall_avg_late_rate, 0), 4) AS seasonality_index
        FROM overall_avg
    )
SELECT
    month_num,
    month_name,
    total_orders,
    total_late_deliveries,
    late_rate_pct,
    ROUND(overall_avg_late_rate, 2) AS overall_avg_late_rate,
    seasonality_index,
    RANK() OVER (ORDER BY seasonality_index DESC) AS rank
FROM seasonality
ORDER BY rank;