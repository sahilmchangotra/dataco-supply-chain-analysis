--==========================================================================================
-- INTRODUCING : LOGISTICS Practice SQL
-- ✅ Q8 -  JET SODA Courier Operations:
-- "My ops team flagged something suspicious. Some orders show a shipping date that is more than 7
-- days after the scheduled shipping date — we're calling these 'ghost shipments'. They sit in the
-- system looking active but nothing is actually moving.
-- I need to know how bad this problem is. Show me:
--
-- Shipping mode
-- Total orders
-- Ghost shipments (shipping date > scheduled date + 7 days)
-- Ghost shipment rate %
-- Avg gap between shipping date and scheduled date (for ghost shipments only)
-- Rank by ghost shipment rate descending — worst mode first
--
-- Same filters as always. Flag First Class separately — you know why."

--  JET SODA Courier Operations (revised)
--Given the dataset caps at 6 days, redefine ghost shipments as orders where the shipping gap exceeds 5 days.
-- Same output as before — shipping mode, total orders, ghost shipments, rate %, avg gap for ghost shipments only,
-- First Class flag, rank by rate descending."

--==========================================================================================
WITH shipped_orders AS
    (SELECT shipping_mode,
            COUNT(order_id)  AS total_orders,
            SUM(CASE
                WHEN (shipping_date::DATE - order_date::DATE) > 5
                THEN 1 ELSE 0
            END) AS total_ghost_shipments,
        ROUND(SUM(CASE
                      WHEN (shipping_date::DATE - order_date::DATE) > 5
                      THEN 1 ELSE 0
                  END) * 100.0 / NULLIF(COUNT(order_id), 0), 2) AS ghost_shipment_rate_pct,
            ROUND(AVG(shipping_date::DATE - order_date::DATE)
            FILTER (WHERE (shipping_date::DATE - order_date::DATE) > 5)::NUMERIC,2) AS avg_gap_ghost_shipment,
         CASE
             WHEN shipping_mode = 'First Class'
            THEN '⚠️ Data Quality Issue — 100% Late'
            ELSE '✅'
        END AS data_quality_flag
FROM supply_chain.orders
WHERE order_status IN ('CLOSED'
    , 'COMPLETE')
  AND delivery_status != 'Shipping canceled'
GROUP BY shipping_mode
 ),
    ranking AS(
        SELECT
            *,
            RANK() OVER (ORDER BY ghost_shipment_rate_pct DESC) AS rank
        FROM shipped_orders
    )

SELECT
    shipping_mode,
    total_orders,
    total_ghost_shipments,
    ghost_shipment_rate_pct,
    avg_gap_ghost_shipment,
    data_quality_flag,
    rank
FROM ranking
ORDER BY rank;