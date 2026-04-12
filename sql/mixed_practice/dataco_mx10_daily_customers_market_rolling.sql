--================================================================================================================
-- Introducing - Mixed Practice Block:
-- 📧 MX10 —  JET SODA Network Planning:
--
-- This is the last piece I need for our market capacity report. For each market, I want to see daily active unique
-- customers with a 30-day rolling average alongside it. This helps us smooth out day-to-day noise and spot genuine
-- demand trends per market over time. Output: market, order_date, daily_customers, rolling_30day_avg.
-- Order by market and date.
--================================================================================================================

WITH order_base AS(
    SELECT
        market,
        order_date::DATE AS order_date,
        COUNT(DISTINCT customer_id) AS daily_customers
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY market, order_date::DATE
)
SELECT
    market,
    order_date,
    daily_customers,
    ROUND(AVG(daily_customers) OVER (
        PARTITION BY market
        ORDER BY order_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ), 2) AS rolling_30d_avg
FROM order_base
ORDER BY market, order_date;