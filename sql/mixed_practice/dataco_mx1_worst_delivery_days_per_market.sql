--================================================================================================================
-- Introducing - Mixed Practice Block:
-- 📧 MX1 — JET SODA Logistics:
--
-- "I want to know which specific dates had the worst late delivery rates in each market. Not averages —
-- actual calendar dates. Give me the top 3 worst days per market ranked by late rate, minimum 10 orders on that
-- day to filter noise."
--================================================================================================================

WITH delivery_base AS(
    SELECT
        market,
        order_date::DATE AS order_day,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT order_id) FILTER ( WHERE delivery_status = 'Late delivery' ) AS total_late_delivery,
        ROUND((COUNT(DISTINCT order_id) FILTER ( WHERE delivery_status = 'Late delivery' )) * 100.0 /
                        NULLIF(COUNT(DISTINCT order_id),0), 2) AS late_delivery_rate
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY market, order_date::DATE
    HAVING COUNT(DISTINCT order_id) >= 10
),
    delivery_summary AS(
       SELECT
    market,
    order_day,
    total_orders,
    total_late_delivery,
    late_delivery_rate,
    DENSE_RANK() OVER (PARTITION BY market ORDER BY late_delivery_rate DESC) AS rank
FROM delivery_base
    )
SELECT
    *
FROM delivery_summary
WHERE rank <= 3
ORDER BY rank;