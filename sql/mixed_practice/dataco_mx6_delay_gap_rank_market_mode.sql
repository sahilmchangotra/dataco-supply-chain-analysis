--================================================================================================================
-- Introducing - Mixed Practice Block:
-- 📧 MX6 —  DLL Process Analyst:
--
--  I'm preparing a carrier-market performance report for our operations board. For each combination of market and
--  shipping mode, I want to rank the months by average delay gap — the difference between actual and scheduled
--  shipping days. Show me the worst month per market-mode combination. Output: market, shipping_mode, month,
--  avg_delay_gap, rank. This will help us identify which market-mode combinations are deteriorating over time.
--================================================================================================================

WITH order_base AS(
    SELECT
        market,
        shipping_mode,
        DATE_TRUNC('month',order_date) AS month,
        ROUND(AVG(days_for_shipping_real - days_for_shipment_scheduled), 2) AS avg_delay_gap
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY market, shipping_mode, DATE_TRUNC('month',order_date)
),
    ranking AS(
        SELECT
            *,
            DENSE_RANK() OVER (
                PARTITION BY market, shipping_mode
                ORDER BY avg_delay_gap DESC) AS rank
        FROM order_base
    )
SELECT
    market,
    shipping_mode,
    TO_CHAR(month,'YYYY-MM') AS month,
    avg_delay_gap,
    rank
FROM ranking
WHERE rank = 1
ORDER BY avg_delay_gap DESC;