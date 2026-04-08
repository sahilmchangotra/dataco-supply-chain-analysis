--==========================================================================================
-- INTRODUCING : LOGISTICS Practice SQL
-- ✅ Q3 -  DataCo Logistics Operations:
-- "We operate across 5 global markets — Africa, Europe, LATAM, Pacific Asia and USCA. My regional
-- directors are asking me which markets have the worst delivery SLA performance.
-- I want to define SLA breach as any order where the real shipping days exceeded the scheduled
-- shipping days by more than 1 day. Not just late delivery status — I want the actual day calculation.
-- For each market show me:
--
-- Total orders
-- SLA breached orders
-- SLA breach rate %
-- Average delay gap (real minus scheduled)
-- Average real shipping days
-- Average scheduled shipping days
-- Rank by breach rate descending — worst market first
--
-- Minimum 1,000 orders per market to be included. I want to present this at our Q1 regional review."
--==========================================================================================


WITH market_performance AS(
    SELECT
        market,
        COUNT(order_id) AS total_orders,
        SUM(CASE WHEN days_for_shipping_real > days_for_shipment_scheduled + 1
                THEN 1 ELSE 0 END) AS total_sla_breached_orders,
        ROUND(SUM(CASE WHEN days_for_shipping_real > days_for_shipment_scheduled + 1
                THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(order_id),0)::NUMERIC, 2) AS sla_breach_rate_pct,
        ROUND((AVG(days_for_shipping_real) - AVG(days_for_shipment_scheduled))::NUMERIC, 2) AS avg_delay_gap,
        ROUND(AVG(days_for_shipping_real),2) AS avg_shipping_days_real,
        ROUND(AVG(days_for_shipment_scheduled),2) AS avg_shipping_days_scheduled
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY market
    HAVING COUNT(order_id) >= 1000
),
    ranking_market AS(
        SELECT
            *,
            RANK() OVER (ORDER BY sla_breach_rate_pct DESC) AS rank
        FROM market_performance
    )
SELECT
    market,
    total_orders,
    total_sla_breached_orders,
    sla_breach_rate_pct,
    avg_delay_gap,
    avg_shipping_days_real,
    avg_shipping_days_scheduled,
    rank
FROM ranking_market
ORDER BY rank;