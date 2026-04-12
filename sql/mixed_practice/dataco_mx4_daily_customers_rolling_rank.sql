--================================================================================================================
-- Introducing - Mixed Practice Block:
-- 📧 MX4 —  JET SODA Network Planning:
--
-- I need a daily customer activity report with context. Can you pull daily unique customer counts, add a 7-day rolling
-- average alongside it, and then rank the top 5 spike days — days where the actual count was significantly above the
-- rolling average? Output: order_date, daily_customers, rolling_7day_avg, daily_rank. Show top 5 spikes only. I want
-- to understand if our spikes are predictable or random."
--================================================================================================================

WITH customer_base AS(
    SELECT
        order_date::DATE AS order_date,
        COUNT(DISTINCT customer_id) AS daily_customer_count
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY order_date::DATE
),
    rolling As(
        SELECT
            order_date,
            daily_customer_count,
            ROUND(AVG(daily_customer_count) OVER (
                ORDER BY order_date
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
                ), 2) AS rolling_7d_avg
        FROM customer_base
    ),
    ranking AS(
        SELECT
            order_date,
            daily_customer_count,
            rolling_7d_avg,
            ROUND(daily_customer_count - rolling_7d_avg, 2) AS spike_gap,
            RANK() OVER (ORDER BY daily_customer_count DESC) AS rank
        FROM rolling
    )
SELECT
    *
FROM ranking
WHERE rank <= 5
ORDER BY spike_gap DESC;