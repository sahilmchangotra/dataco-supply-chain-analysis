--================================================================================================================
-- INTRODUCING : DLL Process Efficiency
-- ✅ Q5 -   DLL Process Analyst:
-- The last piece I need is a root cause analysis. When delivery performance is poor, I want to know exactly which
-- combination of factors is driving it. Specifically — look at orders where the delay gap is more than 2 days over
-- scheduled. For those orders, find the top 10 combinations of market, shipping mode and department that have the
-- highest late rate and worst avg delay gap.
-- This is the drill-down pattern used in process mining — start broad, then narrow to the exact combination causing
-- the problem.
-- For each market + shipping mode + department combination show me:
--
-- Market
-- Shipping mode
-- Department name
-- Total orders
-- Late deliveries
-- Late rate %
-- Avg delay gap
-- Avg profit ratio
-- Composite risk score: late rate % × avg delay gap
-- Rank by composite risk score descending
-- Top 10 only
--================================================================================================================

WITH order_base AS(
    SELECT
        market,
        shipping_mode,
        department_name,
        COUNT(order_id) AS total_orders,
        COUNT(order_id) FILTER ( WHERE delivery_status = 'Late delivery') AS total_late_deliveries,
        ROUND(COUNT(order_id) FILTER ( WHERE delivery_status = 'Late delivery') * 100.0 /
            NULLIF(COUNT(order_id),0), 2) AS late_rate_pct,
        ROUND(AVG(days_for_shipping_real - days_for_shipment_scheduled),2) AS avg_delay_gap,
        ROUND(AVG(order_item_profit_ratio), 2) AS avg_profit_ratio
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
        AND days_for_shipping_real > days_for_shipment_scheduled + 2
    GROUP BY market, shipping_mode, department_name
),
    composite_risk_score AS (
        SELECT
            *,
            ROUND(late_rate_pct * avg_delay_gap, 2) AS risk_score
        FROM order_base
    )
SELECT
    market,
    shipping_mode,
    department_name,
    total_orders,
    total_late_deliveries,
    late_rate_pct,
    avg_delay_gap,
    avg_profit_ratio,
    risk_score,
    RANK() OVER (ORDER BY risk_score DESC) AS rank
FROM composite_risk_score
ORDER BY rank
LIMIT 10;