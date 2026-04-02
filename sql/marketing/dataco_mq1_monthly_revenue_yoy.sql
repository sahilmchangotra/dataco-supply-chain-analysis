--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Q1 - bol category marketing:
-- "I need to understand how our department revenues are trending year over year. Monthly numbers alone don't tell
-- me enough — I need to see each department's revenue this month versus the same month last year, and the growth
-- percentage between them.
-- For each month and department show me:
--
-- Month
-- Department name
-- Total revenue
-- Revenue same month last year (LAG 12)
-- YoY growth %
-- Trend flag: Growing, Declining, or New (no prior year data)
--
-- Same filters as always."
--===============================================================================================================

WITH department_base AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        department_name,
        SUM(sales) AS total_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY DATE_TRUNC('month', order_date), department_name
),
    last_year AS (
        SELECT
            *,
            LAG(total_revenue, 12) OVER (
                PARTITION BY department_name
                ORDER BY month
                ) AS revenue_lyr
        FROM department_base
    ),
    yoy AS(
        SELECT
            *,
            ROUND((total_revenue - revenue_lyr) * 100.0 /
                  NULLIF(revenue_lyr,0), 2) AS yoy_growth_pct
        FROM last_year
    ),
    flagging AS (
        SELECT
            *,
            CASE
                WHEN revenue_lyr IS NULL THEN 'New'
                WHEN total_revenue < revenue_lyr THEN 'Declining'
                WHEN total_revenue > revenue_lyr THEN 'Growing'
                ELSE 'Stable'
            END AS trend_flag
        FROM yoy
    )
SELECT
    TO_CHAR(month, 'YYYY-MM') AS month,
    department_name,
    total_revenue,
    revenue_lyr,
    yoy_growth_pct,
    trend_flag
FROM flagging
ORDER BY month;