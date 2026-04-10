--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ1 — Flipkart Data Analyst Interview:
 --
-- "We want to understand daily platform activity. For each day in the last 7 days of the dataset, show how many
-- unique customers placed an order. Also show the 7-day rolling average to smooth daily noise, and rank the days
-- by unique customer count — highest activity day = rank 1."
--================================================================================================================

WITH ref_date AS(
    SELECT
        MAX(order_date::DATE) AS max_date
    FROM supply_chain.orders
),
    customer_activity AS(
        SELECT
            order_date::DATE AS order_day,
            COUNT(DISTINCT customer_id) AS customer_count
        FROM supply_chain.orders, ref_date
        WHERE order_status IN ('CLOSED', 'COMPLETE')
            AND delivery_status != 'Shipping canceled'
            AND order_date >= max_date - INTERVAL '6 days'
        GROUP BY order_date::DATE
    )
SELECT
    order_day,
    customer_count,
    ROUND(AVG(customer_count) OVER (
        ORDER BY order_day
        ROWS BETWEEN 6 PRECEDING
        AND CURRENT ROW
        ), 2) AS rolling_7d_avg,
    RANK() OVER (ORDER BY customer_count DESC) AS rank
FROM customer_activity
ORDER BY rank;