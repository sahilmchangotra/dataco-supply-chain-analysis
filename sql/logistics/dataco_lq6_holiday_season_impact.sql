SELECT
        CASE
            WHEN (EXTRACT(MONTH FROM order_date) = 11 AND EXTRACT(DAY FROM order_date) >= 15)
                    OR EXTRACT(MONTH FROM order_date) = 12
            THEN 'Holiday Period'
            ELSE 'Normal Period'
        END AS period_label,
        COUNT(order_id) AS total_orders,
        SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS total_late_deliveries,
        ROUND(SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 /
                NULLIF(COUNT(order_id),0)::NUMERIC, 2) AS late_delivery_rate_pct,
        ROUND(AVG(days_for_shipping_real), 2) AS avg_shipping_days_real,
        ROUND(AVG(days_for_shipment_scheduled), 2) AS avg_shipping_days_scheduled,
        ROUND((AVG(days_for_shipping_real) - AVG(days_for_shipment_scheduled)), 2) AS delay_gap
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY CASE
            WHEN (EXTRACT(MONTH FROM order_date) = 11 AND EXTRACT(DAY FROM order_date) >= 15)
                    OR EXTRACT(MONTH FROM order_date) = 12
            THEN 'Holiday Period'
            ELSE 'Normal Period'
        END
    ORDER BY period_label;