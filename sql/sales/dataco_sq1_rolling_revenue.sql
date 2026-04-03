--================================================================================================================
-- INTRODUCING : Sales & Marketing Integrated Questions
-- ✅ Q1 -  Revenue Analytics:
--"I need a daily revenue dashboard with a rolling signal. Show me daily revenue and orders, a 7-day
-- rolling average to smooth the noise, and then surface the top 5 days where revenue spiked most above the
-- rolling average — these are our best performing days and I want to understand what drove them.
-- For the full daily series show me:
--
-- Order date
-- Daily revenue
-- Daily orders
-- 7-day rolling avg revenue
-- Revenue vs rolling avg (daily revenue minus rolling avg)
--
-- Then separately show the top 5 spike days ranked by how far above the rolling average they were.
-- Same filters as always."
--================================================================================================================

WITH daily_orders AS(
    SELECT
        DATE(order_date) as order_day,
        SUM(sales) AS daily_revenue,
        COUNT(order_id) AS daily_orders
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY order_day
),
    rolling_average AS(
        SELECT
            *,
            ROUND(AVG(daily_revenue) OVER (
                ORDER BY order_day
                ROWS BETWEEN 6 PRECEDING AND
                CURRENT ROW ),2) AS rolling_7d_avg
        FROM daily_orders
    )
SELECT
    order_day,
    daily_revenue,
    daily_orders,
    rolling_7d_avg,
    ROUND((daily_revenue - rolling_7d_avg), 2) AS revenue_vs_rolling
FROM rolling_average
ORDER BY order_day;

WITH daily_orders AS(
    SELECT
        DATE(order_date) as order_day,
        SUM(sales) AS daily_revenue,
        COUNT(order_id) AS daily_orders
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY order_day
),
    rolling_average AS(
        SELECT
            *,
            ROUND(AVG(daily_revenue) OVER (
                ORDER BY order_day
                ROWS BETWEEN 6 PRECEDING AND
                CURRENT ROW ),2) AS rolling_7d_avg
        FROM daily_orders
    )
SELECT
    order_day,
    daily_revenue,
    daily_orders,
    rolling_7d_avg,
    ROUND((daily_revenue - rolling_7d_avg), 2) AS revenue_vs_rolling
FROM rolling_average
ORDER BY (daily_revenue - rolling_7d_avg) DESC
LIMIT 5;