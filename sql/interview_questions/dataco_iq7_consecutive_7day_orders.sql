--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ7 — Flipkart Engineering Analytics:
--
-- "We're building a loyalty streak feature. Before we go live, the analytics team wants to validate the
-- logic on historical data. Can you find all customers who have placed at least one order on 7 consecutive calendar
-- days at any point in our dataset? We want to see the customer_id, the streak start date, streak end date, and
-- streak length in days. This will be used to calibrate the reward threshold."
--================================================================================================================

WITH customer_base AS(
    SELECT
        DISTINCT customer_id,
        order_date::DATE AS order_date
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
),
    flag AS(
        SELECT
            customer_id,
            order_date,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
        FROM customer_base
    ),
    aggregate AS(
        SELECT
            customer_id,
            order_date,
            (order_date) - rn * INTERVAL '1 day' AS streak_group
        FROM flag
    )
SELECT
    customer_id,
    COUNT(*) AS streak_length,
    MIN(order_date) AS streak_start,
    MAX(order_date) AS streak_end
FROM aggregate
GROUP BY customer_id ,streak_group
HAVING COUNT(*) >= 7
ORDER BY streak_group DESC
LIMIT 10;