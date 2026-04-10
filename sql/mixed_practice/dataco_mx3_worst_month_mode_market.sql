--================================================================================================================
-- Introducing - Mixed Practice Block:
-- 📧 MX3 —  DLL Process Analyst:
--
-- I want to find the single worst performing month for each shipping mode and market combination — worst meaning
-- highest SLA breach rate. This tells me exactly which mode-market-month combination needs the most urgent investigation.
-- Show me:
--
-- Shipping mode
-- Market
-- Month
-- Total orders
-- SLA breached orders
-- SLA breach rate %
-- Rank within shipping mode + market (ROW_NUMBER — only want rank 1)
-- First Class data quality flag as always
--================================================================================================================

WITH  order_base AS(
    SELECT
        shipping_mode,
        market,
        DATE_TRUNC('month', order_date) AS month,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT order_id) FILTER ( WHERE days_for_shipping_real > days_for_shipment_scheduled + 1 ) AS sla_breached_orders,
        ROUND((COUNT(DISTINCT order_id) FILTER
            ( WHERE days_for_shipping_real > days_for_shipment_scheduled + 1 ) ) * 100.0 /
              NULLIF(COUNT(DISTINCT order_id), 0), 2) AS sla_breach_rate
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY shipping_mode, market, DATE_TRUNC('month', order_date)
    HAVING COUNT(DISTINCT order_id) >= 20
),
    ranking AS(
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY shipping_mode, market
                ORDER BY sla_breach_rate DESC
                ) AS rank
        FROM order_base
    )
SELECT
    shipping_mode,
    market,
    TO_CHAR(month, 'YYYY-MM') AS month,
    total_orders,
    sla_breached_orders,
    sla_breach_rate,
    rank,
    CASE
         WHEN shipping_mode = 'First Class'
        THEN '⚠️ Data Quality Issue — 100% Late'
        ELSE '✅'
    END AS data_quality_flag
FROM ranking
WHERE rank = 1
ORDER BY rank;