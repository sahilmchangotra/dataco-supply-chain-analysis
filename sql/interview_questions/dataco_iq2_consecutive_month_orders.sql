--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ2 — Amazon Data Analyst Interview:
--
-- "Find all customers who placed orders in at least 3 consecutive months. Return the customer ID, the starting
-- month of their consecutive streak, and how many consecutive months they ordered."
--================================================================================================================

WITH ref_date AS(
    SELECT
        customer_id,
        DATE_TRUNC('month', order_date) AS order_month
    FROM supply_chain.orders
    WHERE order_status IN ('COMPLETE', 'CLOSED')
        AND delivery_status != 'Shipping canceled'
    ),
    flag AS(
        SELECT
            customer_id,
            order_month,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_month) AS rn
        FROM ref_date
    ),
    aggregate AS(
        SELECT
            customer_id,
            order_month,
            (order_month) - rn * INTERVAL '1 month' AS streak_group
        FROM flag
    )
SELECT
    DISTINCT ON (customer_id)
    customer_id,
    COUNT(*) AS streak_length,
    MIN(order_month) AS streak_start,
    MAX(order_month) AS streak_end
FROM aggregate
GROUP BY customer_id, streak_group
HAVING COUNT(*) >= 3
ORDER BY customer_id, streak_length DESC;
