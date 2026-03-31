--===============================================================================================================
-- INTRODUCING : LOGISTICS Practice SQL
-- ✅ Q9 - JET SODA Senior Logistics:
-- "I need to understand whether our delivery speed distribution actually improved after July 2017. Split
-- all orders into two periods — before July 2017 and from July 2017 onwards. Within each period, bucket orders
-- into 4 delivery speed tiers using NTILE. Then show me the average real shipping days per tier per period. I
-- want to see if the fast tier got faster and the slow tier got slower — or if the whole distribution shifted."
--===============================================================================================================

-- One row in my base CTE = one period
WITH orders_base AS(
    SELECT
        CASE
            WHEN DATE(order_date) < '2017-07-01' THEN 'Before Jul 2017'
            ELSE 'Jul 2017 onwards'
        END AS period,
        order_id,
        days_for_shipping_real
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
),
    quantiled AS(
        SELECT
            *,
            NTILE(4) OVER (PARTITION BY period ORDER BY days_for_shipping_real ASC) AS speed_tier
        FROM orders_base
    )
SELECT
    period,
    speed_tier,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(days_for_shipping_real), 2) AS avg_shipping_days_real
FROM quantiled
GROUP BY period, speed_tier
ORDER BY period, speed_tier;