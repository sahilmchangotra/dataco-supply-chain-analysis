--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ10 — Nykaa Growth Analytics:
--
-- I'm doing a buyer retention review for our category leads. I want to understand how many customers who
-- placed their first order in a given month came back and placed another order in the following month.
-- Show me the monthly cohort — acquisition month, number of new customers acquired, how many came back next month,
-- and the retention rate as a percentage. This will go into our quarterly retention deck."
--================================================================================================================

WITH first_order AS(
    SELECT
        customer_id,
        DATE_TRUNC('month',MIN(order_date))::DATE AS first_order_month
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY customer_id
),
    retained AS(
        SELECT
            f.customer_id,
            f.first_order_month,
            o.customer_id AS returning_customer_id
        FROM first_order f
        LEFT JOIN supply_chain.orders o
            ON f.customer_id = o.customer_id
            AND DATE_TRUNC('month', o.order_date) = f.first_order_month + INTERVAL '1 month'
            AND o.order_status IN ('CLOSED', 'COMPLETE')
    )
SELECT
    first_order_month,
    COUNT(DISTINCT customer_id) AS new_customers,
    COUNT(DISTINCT returning_customer_id) AS retained,
    ROUND(COUNT(DISTINCT returning_customer_id) * 100.0 /
          NULLIF(COUNT(DISTINCT customer_id), 0), 2) AS retention_rate_pct
FROM retained
GROUP BY first_order_month
ORDER BY first_order_month;