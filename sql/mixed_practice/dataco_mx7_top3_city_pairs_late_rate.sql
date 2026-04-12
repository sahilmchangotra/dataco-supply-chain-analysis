--================================================================================================================
-- Introducing - Mixed Practice Block:
-- 📧 MX7 —  JET SODA Logistics Operations:
--
--  I  want to understand which city-to-city routes are consistently failing on delivery. For each unique route —
--  defined as order city paired with customer city — show me the late delivery rate as a percentage. Then give me
--  the top 3 worst performing routes with at least 10 orders. Output: order_city, customer_city, total_orders,
--  late_orders, late_rate_pct, rank. I want to escalate the worst routes to our carrier partners.
--================================================================================================================

WITH order_base AS(
    SELECT
        order_city ||'->'|| customer_city AS route,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT order_id) FILTER (WHERE days_for_shipping_real > days_for_shipment_scheduled) AS late_orders,
        ROUND(COUNT(DISTINCT order_id) FILTER
            (WHERE days_for_shipping_real > days_for_shipment_scheduled) * 100.0 /
            NULLIF(COUNT(DISTINCT order_id),0), 2) AS late_rate_pct
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY order_city ||'->'|| customer_city
    HAVING COUNT(DISTINCT order_id) >= 10
),
    ranking AS(
        SELECT
            *,
            DENSE_RANK() OVER (ORDER BY late_rate_pct DESC) AS rank
        FROM order_base
    )

SELECT
    route,
    total_orders,
    late_orders,
    late_rate_pct,
    rank
FROM
    ranking
WHERE rank <= 3
ORDER BY rank;