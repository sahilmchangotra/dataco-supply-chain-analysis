--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ14 — Ola City Operations:
--
-- I'm doing a demand planning review for our city operations team. For each city, I need to know the peak hour of
-- the day — the hour that consistently has the highest order volume. This will help us optimise driver allocation
-- per city per hour. Output: order_city, peak_hour, total_orders_in_that_hour. Rank cities by their peak hour order
-- volume so we can prioritise the busiest ones first.
--================================================================================================================

WITH order_base AS(
    SELECT
        order_city,
        EXTRACT(HOUR FROM order_date) AS hour,
        COUNT(DISTINCT order_id) AS total_orders
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY order_city, EXTRACT(HOUR FROM order_date)
),
    ranked AS(
        SELECT
            *,
            DENSE_RANK() OVER (PARTITION BY order_city ORDER BY total_orders DESC) AS rank
        FROM order_base
    )
SELECT
    order_city,
    hour AS peak_hour,
    total_orders,
    rank
FROM ranked
WHERE rank = 1
ORDER BY total_orders DESC;