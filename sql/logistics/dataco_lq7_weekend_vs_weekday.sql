--==========================================================================================
-- INTRODUCING : LOGISTICS Practice SQL
-- ✅ Q7 -  DataCo Network Planning:
-- "I keep hearing anecdotally that weekend orders have worse delivery performance — people
-- place orders Friday night, nothing moves Saturday, and it all piles up Monday. I need the data to
-- either confirm or kill that theory.
-- Split orders into Weekday vs Weekend based on the order date. For each group show me:
--
-- Period label
-- Total orders
-- Total late deliveries
-- Late delivery rate %
-- Avg real shipping days
-- Avg scheduled shipping days
-- Delay gap (real minus scheduled)
--
-- Same filters as always. I want to bring this to our network planning meeting Friday."
--==========================================================================================


    SELECT
        CASE
            WHEN EXTRACT(DOW FROM order_date) IN (0, 6)
                THEN 'Weekend'
            ELSE 'Weekday'
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
            WHEN EXTRACT(DOW FROM order_date) IN (0, 6)
                THEN 'Weekend'
            ELSE 'Weekday'
        END
    ORDER BY period_label;