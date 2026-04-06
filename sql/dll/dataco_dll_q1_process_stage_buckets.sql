--================================================================================================================
-- INTRODUCING : DLL Process Efficiency
-- ✅ Q1 -   DLL Process Analyst:
--"At DLL we think in terms of process efficiency — how long does it take from order placement to delivery,
-- and are we meeting our own targets? I need you to analyse end-to-end process time for each order and bucket them
-- into performance stages.
-- Define the stages as:
--
-- Fast: delivered in less than or equal to scheduled days
-- Normal: 1–2 days over scheduled
-- Slow: 3–5 days over scheduled
-- Critical: more than 5 days over scheduled
--
-- For each stage show me:
--
-- Stage label
-- Total orders
-- % of total orders
-- Avg real shipping days
-- Avg scheduled shipping days
-- Avg delay gap (real minus scheduled)
-- Avg profit ratio (does slower delivery hurt profit?)
--================================================================================================================
---- NOTE: Critical stage (>5 days over scheduled) returns 0 orders
-- DataCo max real shipping days = 6, max scheduled = 4 (Standard Class)
-- Maximum possible gap = 2 days for Standard Class → Critical threshold
-- unreachable in this dataset. Flag for DLL process mining context.

WITH staged AS(
    SELECT
            CASE
                WHEN days_for_shipping_real <= days_for_shipment_scheduled THEN 'Fast'
                WHEN days_for_shipping_real <= days_for_shipment_scheduled + 2 THEN 'Normal'
                WHEN days_for_shipping_real <= days_for_shipment_scheduled + 5 THEN 'Slow'
                ELSE 'Critical'
            END AS process_stage,
            days_for_shipping_real,
            days_for_shipment_scheduled,
            order_id,
            order_item_profit_ratio
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
    AND delivery_status != 'Shipping canceled'
),
    aggregated AS(
        SELECT
            process_stage,
            COUNT(order_id) AS total_orders,
            ROUND(COUNT(order_id) * 100.0 / NULLIF(SUM(COUNT(order_id)) OVER (),0), 2) AS pct_of_total_orders,
            ROUND(AVG(days_for_shipping_real), 2) AS avg_shipping_days_real,
            ROUND(AVG(days_for_shipment_scheduled), 2) AS avg_shipping_days_scheduled,
            ROUND(AVG(days_for_shipping_real - days_for_shipment_scheduled), 2) AS avg_delay_gap,
            ROUND(AVG(order_item_profit_ratio), 2) AS avg_profit_ratio
        FROM staged
        GROUP BY process_stage
    )
SELECT
    *
FROM aggregated
ORDER BY CASE process_stage
        WHEN 'Fast' THEN 1
        WHEN 'Normal'   THEN 2
    WHEN 'Slow'     THEN 3
    WHEN 'Critical' THEN 4 END;