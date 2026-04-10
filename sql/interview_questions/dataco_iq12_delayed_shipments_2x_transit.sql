--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ12 — DHL/FedEx Logistics Analytics:
--
-- I'm reviewing our shipment performance for a carrier audit. I need to identify shipments where the actual
-- delivery time was more than 2x the scheduled delivery time — these are our most severely delayed shipments.
-- For each shipping mode, show me the total shipments, how many breached the 2x threshold, the breach rate as a
-- percentage, and the average delay gap for breached shipments only. Rank the shipping modes from worst to best breach rate.
--================================================================================================================

WITH shipment_base AS(
    SELECT
        shipping_mode,
        COUNT(DISTINCT order_id) AS total_shipments,
        COUNT(DISTINCT order_id) FILTER (
            WHERE days_for_shipping_real > days_for_shipment_scheduled * 2) AS sla_breached_orders,
        ROUND(AVG(days_for_shipping_real - days_for_shipment_scheduled) FILTER ( WHERE
                            days_for_shipping_real > days_for_shipment_scheduled * 2), 2) AS avg_breached_days,
        ROUND(COUNT(DISTINCT order_id) FILTER (
            WHERE days_for_shipping_real > days_for_shipment_scheduled * 2) * 100.0 /
        NULLIF(COUNT(DISTINCT order_id),0),2) AS breach_rate_pct
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY shipping_mode
)
SELECT
    shipping_mode,
    total_shipments,
    sla_breached_orders,
    breach_rate_pct,
    avg_breached_days,
    CASE
        WHEN shipping_mode = 'First Class'
        THEN '⚠️ Data Quality Issue — 100% Late'
        ELSE '✅'
    END AS data_quality_flag,
    DENSE_RANK() OVER (ORDER BY breach_rate_pct DESC) AS rank
FROM shipment_base
ORDER BY rank;