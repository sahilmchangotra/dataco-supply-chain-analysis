--================================================================================================================
-- INTRODUCING : Cohort Questions
-- ✅ Q4 - BOL category marketing:
-- I want to understand which product categories have the strongest repeat purchase behaviour within 30 days — and
-- whether repeat rate differs by customer segment. This will tell me where to focus loyalty campaigns.
-- For each category + customer segment combination show me:
--
-- Category name
-- Customer segment
-- Total unique customers
-- Customers who repeated within 30 days
-- 30-day repeat rate %
-- Avg days to repeat order
-- Avg first order revenue
-- Avg repeat order revenue
--
-- Only include category + segment combinations with at least 50 customers.
-- Order by repeat rate descending.
--================================================================================================================

WITH order_base AS(
    SELECT
        category_name,
        customer_segment,
        customer_id,
        order_id,
        MIN(order_date) AS order_date,
        SUM(sales) AS order_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY category_name, customer_segment, customer_id, order_id
),
    with_flag AS(
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY customer_id, category_name ORDER BY order_date) AS order_rank
        FROM order_base
    ),
    new_customer AS(
        SELECT
            customer_id,
            category_name,
            customer_segment,
            order_date AS first_order_date,
            order_revenue AS first_order_revenue
        FROM with_flag
        WHERE order_rank = 1
    ),
    window_30d AS(
        SELECT
            nc.customer_id,
            nc.first_order_date,
            nc.first_order_revenue,
            ob.category_name,
            ob.customer_segment,
            ob.order_id,
            ob.order_date,
            ob.order_revenue
        FROM new_customer nc
        JOIN order_base ob
            ON nc.customer_id = ob.customer_id
            AND nc.category_name = ob.category_name
            AND ob.order_date <= nc.first_order_date + INTERVAL '30 days'
    ),
    customer_summary AS(
        SELECT
            w.customer_id,
            w.category_name,
            w.customer_segment,
            nc.first_order_revenue,
            nc.first_order_date,
            COUNT(DISTINCT w.order_id) AS orders_in_30d,
            CASE WHEN COUNT(DISTINCT w.order_id) > 1 THEN 1 ELSE 0 END AS repeat_flag,
            MIN(CASE WHEN w.order_date::DATE > nc.first_order_date::DATE
                    THEN w.order_date::DATE - nc.first_order_date::DATE END) AS days_to_repeat,
            AVG(CASE WHEN w.order_date::DATE > nc.first_order_date::DATE
                THEN w.order_revenue END) AS avg_repeat_revenue
        FROM window_30d w
        JOIN new_customer nc
        ON w.customer_id = nc.customer_id
        AND w.category_name = nc.category_name
        GROUP BY w.customer_id, w.category_name, w.customer_segment, nc.first_order_revenue, nc.first_order_date
    )
SELECT
    category_name,
    customer_segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(repeat_flag) AS repeat_customers,
    ROUND(SUM(repeat_flag) * 100.0 / NULLIF(COUNT(DISTINCT customer_id),0), 2) AS repeat_rate_30d,
    ROUND(AVG(days_to_repeat), 2) AS avg_days_to_repeat,
    ROUND(AVG(first_order_revenue), 2) AS avg_first_order_revenue,
   ROUND(AVG(avg_repeat_revenue), 2) AS avg_repeat_revenue
FROM customer_summary
GROUP BY category_name, customer_segment
HAVING COUNT(DISTINCT customer_id) >= 50
ORDER BY repeat_rate_30d DESC;