--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Q3 - bol category marketing:
-- "I need to understand which months are structurally our highest revenue months — not just one good year, but a
-- repeatable seasonal pattern. Same concept as the delivery seasonality index you built for Beatriz, but for
-- revenue this time.
-- For each month show me:
--
-- Month number (1–12)
-- Month name
-- Total revenue across all years
-- Avg monthly revenue for that month across all years
-- Overall avg monthly revenue across all 12 months
-- Seasonality index (month avg / overall avg)
-- Rank by index descending — best revenue month first
--
-- Same filters as always."
--===============================================================================================================

WITH revenue_base AS (
    SELECT
        EXTRACT(MONTH FROM order_date)::INT AS month_num,
        SUM(sales) AS total_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
      AND delivery_status != 'Shipping canceled'
    GROUP BY EXTRACT(MONTH FROM order_date)::INT
),
average_revenue AS (
    SELECT
        month_num,
        TO_CHAR(TO_DATE(month_num::TEXT, 'MM'), 'Month') AS month_name,
        total_revenue,
        ROUND(AVG(total_revenue) OVER (), 2) AS overall_avg_revenue,
        ROUND(total_revenue / AVG(total_revenue) OVER (), 4) AS seasonality_index
    FROM revenue_base
)
SELECT
    month_num,
    month_name,
    total_revenue,
    overall_avg_revenue,
    seasonality_index,
    RANK() OVER (ORDER BY seasonality_index DESC) AS rank
FROM average_revenue
ORDER BY rank;