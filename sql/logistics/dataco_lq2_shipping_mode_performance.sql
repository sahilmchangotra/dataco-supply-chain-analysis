--==========================================================================================
-- INTRODUCING : LOGISTICS Practice SQL
-- ✅ Q2 -  DataCo Network Planning:

-- I need to understand which shipping modes are actually performing well and which ones are letting us down.
-- We offer four shipping modes — First Class, Second Class, Standard Class and Same Day.
-- For each shipping mode I want to see:
--
-- Total orders
-- Average real shipping days (actual)
-- Average scheduled shipping days (what we promised)
-- The delay gap — difference between real and scheduled
-- Late delivery rate %
-- Rank by worst delay gap — I want to see which mode has the biggest gap between promise and reality
--
-- This will help me decide where to invest in network improvement and which shipping partners need performance review meetings."
--==========================================================================================

-- One row in base CTE = one order
-- Note: First Class shows 100% late delivery rate — DataCo dataset issue
-- First Class has no 'Shipping on time' or 'Advance shipping' records
-- Standard Class is the only mode with 'Advance shipping' status

WITH shipping_performance AS(
    SELECT
        shipping_mode,
            COUNT(order_id) AS total_orders,
            COUNT(order_id) FILTER ( WHERE delivery_status = 'Late delivery') AS total_late_orders,
            ROUND(AVG(days_for_shipping_real), 2) AS avg_shipping_days_real,
            ROUND(AVG(days_for_shipment_scheduled), 2) AS avg_shipping_days_scheduled,
            ROUND((AVG(days_for_shipping_real) - AVG(days_for_shipment_scheduled)), 2) AS delay_gap,
            ROUND((COUNT(order_id) FILTER ( WHERE delivery_status = 'Late delivery' )) * 100.0 /
                    NULLIF(COUNT(order_id),0)::NUMERIC, 2) AS late_delivery_rate_pct,
            CASE
                WHEN COUNT(order_id) FILTER ( WHERE
                    delivery_status IN ('Shipping on time', 'Advance shipping')) = 0
                THEN 'Data Quality Issue - No on-time records'
                ELSE 'Valid'
            END AS data_quality_flag
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY shipping_mode
),
    ranking AS(
        SELECT
            *,
            RANK() OVER (ORDER BY delay_gap DESC) AS rank
        FROM shipping_performance
    )
SELECT
    shipping_mode,
    total_orders,
    total_late_orders,
    avg_shipping_days_real,
    avg_shipping_days_scheduled,
    delay_gap,
    late_delivery_rate_pct,
    data_quality_flag,
    rank
FROM ranking
ORDER BY rank;

