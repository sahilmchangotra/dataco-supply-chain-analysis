--================================================================================================================
-- INTRODUCING : DLL Process Efficiency
-- ✅ Q2 -   DLL Process Analyst:
--"In process mining we look for deviations — orders that didn't follow the expected path. For us, an order
-- deviates when the real shipping days are more than double the scheduled days. I want to see these deviations broken
-- down by market and shipping mode — where are the worst deviation hotspots?
-- For each market + shipping mode combination show me:
--
-- Market
-- Shipping mode
-- Total orders
-- Deviation count (real > scheduled × 2)
-- Deviation rate %
-- Avg real shipping days for deviations only
-- Avg delay gap for deviations only
-- Rank by deviation rate descending
-- First Class data quality flag
--================================================================================================================

WITH order_base AS (SELECT market,
                          shipping_mode,
                          order_id,
                          MAX(days_for_shipping_real)      AS days_real,
                          MAX(days_for_shipment_scheduled) AS days_scheduled
                   FROM supply_chain.orders
                   WHERE order_status IN ('CLOSED', 'COMPLETE')
                     AND delivery_status != 'Shipping canceled'
                   GROUP BY market, shipping_mode, order_id),
    order_agg AS(
        SELECT
        market,
        shipping_mode,
        COUNT(order_id) AS total_orders,
        COUNT(order_id) FILTER ( WHERE days_real > days_scheduled * 2 ) AS deviation_count,
        ROUND(COUNT(order_id) FILTER(WHERE days_real > days_scheduled * 2) * 100.0 /
            NULLIF(COUNT(order_id), 0), 2) AS deviation_rate_pct,
        ROUND(AVG(days_real) FILTER(WHERE days_real > days_scheduled * 2), 2) AS avg_real_days,
        ROUND(AVG(days_real - days_scheduled) FILTER(WHERE days_real > days_scheduled * 2), 2) AS avg_delay_gap,
        CASE WHEN shipping_mode = 'First Class'
            THEN '⚠️ Data Quality — 100% Late' ELSE '✅'
        END AS data_quality_flag
    FROM order_base
    GROUP BY market, shipping_mode
)
SELECT
    market,
    shipping_mode,
    total_orders,
    deviation_count,
    deviation_rate_pct,
    avg_real_days,
    avg_delay_gap,
    data_quality_flag,
    RANK() OVER (ORDER BY deviation_rate_pct DESC) AS rank
FROM order_agg
ORDER BY rank;