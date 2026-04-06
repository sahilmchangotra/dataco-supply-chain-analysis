--================================================================================================================
-- INTRODUCING : DLL Process Efficiency
-- ✅ Q3 -   DLL Process Analyst:
--In process mining we identify bottlenecks — stages or agents where the process slows down significantly compared
-- to the network average. I want to find which markets are bottlenecks in our delivery network.
-- For each market show me:
--
-- Market
-- Total orders
-- Avg real shipping days
-- Avg scheduled shipping days
-- Avg delay gap
-- Network avg real shipping days (across all markets)
-- Ratio of market avg to network avg
-- Bottleneck flag: if market avg real days > 2x network avg → 'Critical Bottleneck', if > 1.5x → 'Bottleneck', else → 'Normal'
-- Rank by avg real shipping days descending
--================================================================================================================

WITH
    order_agg AS(
        SELECT
            market,
            COUNT(order_id) AS total_orders,
            ROUND(AVG(days_for_shipping_real), 2) AS avg_days_real,
            ROUND(AVG(days_for_shipment_scheduled), 2) AS avg_days_scheduled,
            ROUND(AVG(days_for_shipping_real - days_for_shipment_scheduled), 2) AS avg_delay_gap,
            ROUND(AVG(AVG(days_for_shipping_real)) OVER (), 2) AS network_avg_real_days
         FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY market
    ),
    bottle_neck AS(
        SELECT
            market,
            total_orders,
            avg_days_real,
            avg_days_scheduled,
            avg_delay_gap,
            network_avg_real_days,
            ROUND(avg_days_real / NULLIF(network_avg_real_days, 0), 2) AS ratio_to_network,
            CASE
                WHEN avg_days_real > network_avg_real_days * 2 THEN 'Critical Bottleneck'
                WHEN avg_days_real > network_avg_real_days * 1.5 THEN 'Bottleneck'
                ELSE 'Normal'
            END AS bottleneck_flag,
            RANK () OVER (ORDER BY avg_days_real DESC) AS rank
        FROM order_agg
    )
SELECT
    market,
    total_orders,
    avg_days_real,
    avg_days_scheduled,
    avg_delay_gap,
    network_avg_real_days,
    ratio_to_network,
    bottleneck_flag,
    rank
FROM bottle_neck
ORDER BY rank;