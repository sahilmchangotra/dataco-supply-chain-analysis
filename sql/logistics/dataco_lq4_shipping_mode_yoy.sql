--==========================================================================================
-- INTRODUCING : LOGISTICS Practice SQL
-- ✅ Q4 -  DataCo Network Planning:
-- "Our logistics board wants to know if our shipping modes are actually improving year over year.
-- Anyone can show me a snapshot — I need to see the trend.
-- For each shipping mode and each month, show me the average real shipping days. Then compare it
-- to the same month last year — so January 2016 vs January 2015, January 2017 vs January 2016 and so on.
-- I want to see:
--
-- Shipping mode
-- Month
-- Average real shipping days this month
-- Average real shipping days same month last year
-- Year over year change in days (positive = getting worse, negative = improving)
-- *Year over year change % *
-- A trend flag — Improving, Worsening, or Stable (within 0.1 days)
--
-- This will tell me which shipping modes are actually getting better and which ones are deteriorating despite
-- our investment."
--==========================================================================================

-- One row in my base CTE = one shipping mode + month

WITH monthly_shipping AS(
    SELECT
        shipping_mode,
        DATE_TRUNC('month', shipping_date) AS ship_year_month,
        ROUND(AVG(days_for_shipping_real), 2) AS avg_shipping_days_real
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY shipping_mode, DATE_TRUNC('month', shipping_date)
),
    last_year_same_month AS(
        SELECT
            shipping_mode,
            ship_year_month,
            avg_shipping_days_real AS current_avg,
            LAG(avg_shipping_days_real, 12) OVER (
                PARTITION BY shipping_mode
                ORDER BY ship_year_month
                ) AS last_year_avg
        FROM monthly_shipping
    ),
    yoy AS(
        SELECT
            *,
            ROUND((current_avg - last_year_avg)::NUMERIC,2) AS yoy_change_in_days,
            ROUND((current_avg - last_year_avg) * 100.0 / NULLIF(last_year_avg, 0)::NUMERIC, 2) AS yoy_change_pct,
            CASE
                WHEN (current_avg - last_year_avg) > 0.1 THEN 'Worsening'
                WHEN (current_avg - last_year_avg) < -0.1 THEN 'Improving'
                ELSE 'Stable'
            END AS trend_flag
        FROM last_year_same_month
    )
SELECT
    shipping_mode,
    TO_CHAR(ship_year_month, 'YYYY-MM') AS ship_year_month,
    current_avg,
    last_year_avg,
    yoy_change_in_days,
    yoy_change_pct,
    trend_flag
FROM yoy
ORDER BY shipping_mode, ship_year_month;