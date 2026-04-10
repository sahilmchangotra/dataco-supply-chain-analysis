--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ11 — BigBasket Customer Analytics:
--
-- I'm doing a customer spend analysis for our loyalty team. For each customer, I want to find their second highest
-- order value — not their best order, but their second best. This helps us understand if high spenders are
-- consistent or just one-time big buyers.
-- Output: customer_id, second highest order value, and their overall total orders.
-- Only show customers who have placed at least 2 orders.
--================================================================================================================

WITH order_base AS(
    SELECT
        customer_id,
        order_id,
        SUM(sales) AS order_value
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY customer_id, order_id
),
    ranked AS(
        SELECT
        *,
        DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_value DESC) AS rank
    FROM order_base
    ),
    order_counts AS(
        SELECT
            customer_id,
            COUNT(DISTINCT order_id) AS total_orders
        FROM supply_chain.orders
        WHERE order_status IN ('COMPLETE', 'CLOSED')
            AND delivery_status != 'Shipping canceled'
        GROUP BY customer_id
    )
SELECT
    r.customer_id,
    r.order_value AS second_highest_order_value,
    oc.total_orders
FROM ranked r
JOIN order_counts oc
    ON r.customer_id = oc.customer_id
WHERE r.rank = 2
    AND oc.total_orders >= 2
ORDER BY second_highest_order_value DESC;