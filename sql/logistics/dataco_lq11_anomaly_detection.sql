--===============================================================================================================
-- INTRODUCING : LOGISTICS Practice SQL
-- ✅ Q11 - JET SODA Courier Operations:
-- "My ops team flagged something worrying. Some orders show real shipping days more than double the
-- scheduled days — these aren't just late deliveries, these are genuine anomalies. Something went badly wrong
-- with these shipments.
-- I want to understand the scale of this problem. For each shipping mode show me:
--
-- Shipping mode
-- Total orders
-- Anomaly count (real days > 2x scheduled days)
-- Anomaly rate %
-- Avg real shipping days for anomalies only
-- Avg scheduled shipping days for anomalies only
-- Avg ratio (real / scheduled) for anomalies only
-- Rank by anomaly rate descending — worst mode first
-- First Class data quality flag as always
--
-- Same filters as always."
--===============================================================================================================

-- One row in my base CTE = shipping mode

WITH shipping_base AS (SELECT shipping_mode,
                              COUNT(order_id)     AS total_orders,
                              SUM(CASE
                                      WHEN days_for_shipping_real > days_for_shipment_scheduled + 2 THEN 1
                                      ELSE 0 END) AS anomaly_count,
                              ROUND(SUM(CASE
                                            WHEN days_for_shipping_real > days_for_shipment_scheduled + 2 THEN 1
                                            ELSE 0 END) * 100.0 /
                                    NULLIF(COUNT(days_for_shipping_real), 0)::NUMERIC,
                                    2)            AS anomaly_rate_pct,
                              ROUND(AVG(days_for_shipping_real) FILTER
                                  (WHERE days_for_shipping_real > days_for_shipment_scheduled + 2),
                                    2)            AS avg_shipping_days_real,
                              ROUND(AVG(days_for_shipment_scheduled) FILTER
                                  (WHERE days_for_shipping_real > days_for_shipment_scheduled + 2),
                                    2)            AS avg_shipping_days_scheduled,
                              ROUND(AVG(days_for_shipping_real - days_for_shipment_scheduled)
                                    FILTER(WHERE days_for_shipping_real > days_for_shipment_scheduled + 2),
                                                2) AS avg_delay_gap
                       FROM supply_chain.orders
                       WHERE order_status IN ('CLOSED', 'COMPLETE')
                         AND delivery_status != 'Shipping canceled'
                       GROUP BY shipping_mode
                       ),
    ranking AS(
        SELECT
            *,
            CASE
                WHEN shipping_mode = 'First Class'
                THEN '⚠️ Data Quality Issue — 100% Late'
                ELSE '✅'
            END AS data_quality_flag,
            RANK() OVER (ORDER BY anomaly_rate_pct DESC) AS rank
        FROM shipping_base
    )
SELECT
    shipping_mode,
    total_orders,
    anomaly_count,
    anomaly_rate_pct,
    avg_shipping_days_real,
    avg_shipping_days_scheduled,
    avg_delay_gap,
    data_quality_flag,
    rank
FROM ranking
ORDER BY rank;
