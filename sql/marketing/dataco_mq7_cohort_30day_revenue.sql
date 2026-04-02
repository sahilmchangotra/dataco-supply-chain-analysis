--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Q7 -  bol category marketing:
-- I want to understand how much revenue customers generate in the 30 days after their first order. This tells us
-- the true value of acquiring a new customer — not just their first purchase but their immediate repeat behaviour.
-- For each customer show me:
--
-- Customer ID
-- First order date
-- First order revenue
-- Total revenue within 30 days of first order (including first order)
-- Number of orders within 30 days
-- Days between first and last order in the 30-day window
--
-- Then summarise overall:
--
-- Avg first order revenue
-- Avg 30-day revenue per customer
-- Avg orders in 30-day window
-- % of customers who placed a repeat order within 30 days
--===============================================================================================================

WITH customer_base AS(
    SELECT
        customer_id,
        order_id,
        order_date,
        sales,
        MIN(order_date) OVER (PARTITION BY customer_id) AS first_order_date
    FROM orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
      AND delivery_status != 'Shipping canceled'
),
    window_30d AS(
        SELECT
            *
        FROM customer_base
        WHERE order_date <= first_order_date + INTERVAL '30 days'
    ),
    customer_summary AS(
        SELECT
            customer_id,
            first_order_date,
            SUM(CASE WHEN order_date = first_order_date THEN sales ELSE 0 END) AS first_order_revenue,
            SUM(sales) AS total_30d_revenue,
            COUNT(DISTINCT order_id) AS orders_in_30d,
            DATE_PART('day', MAX(order_date) - first_order_date) AS days_first_to_last,
            CASE WHEN COUNT(DISTINCT order_id) > 1 THEN 1 ELSE 0 END AS repeat_flag
        FROM window_30d
        GROUP BY customer_id, first_order_date
    )
SELECT
    ROUND(AVG(first_order_revenue), 2) AS avg_first_order_revenue,
    ROUND(AVG(total_30d_revenue), 2)   AS avg_30d_revenue,
    ROUND(AVG(orders_in_30d), 2)       AS avg_orders_in_30d,
    ROUND(AVG(repeat_flag) * 100, 2)   AS repeat_rate_pct
FROM customer_summary;