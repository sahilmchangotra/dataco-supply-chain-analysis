--================================================================================================================
-- Introducing - Mixed Practice Block:
-- 📧 MX8 —  JET SODA Logistics:
--
--  I need a pivot table for our board presentation. Show me total orders broken down by shipping mode as rows and
--  quarter as columns — Q1, Q2, Q3, Q4. This gives leadership a single view of how each shipping mode performs across
--  the year. Output: shipping_mode, q1_orders, q2_orders, q3_orders, q4_orders.
--================================================================================================================


        SELECT
            shipping_mode,
            COUNT(DISTINCT order_id) FILTER ( WHERE EXTRACT('QUARTER' FROM order_date) = 1) AS q1_orders,
            COUNT(DISTINCT order_id) FILTER ( WHERE EXTRACT('QUARTER' FROM order_date) = 2) AS q2_orders,
            COUNT(DISTINCT order_id) FILTER ( WHERE EXTRACT('QUARTER' FROM order_date) = 3) AS q3_orders,
            COUNT(DISTINCT order_id) FILTER ( WHERE EXTRACT('QUARTER' FROM order_date) = 4) AS q4_orders
        FROM supply_chain.orders
        WHERE order_status IN ('CLOSED','COMPLETE')
            AND delivery_status != 'Shipping canceled'
        GROUP BY shipping_mode;