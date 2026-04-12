--================================================================================================================
-- Introducing - Mixed Practice Block:
-- 📧 MX5 —  BOL Performance Marketing:
--
-- I'm building a VIP customer list for our next campaign. For each combination of customer segment
-- (Consumer / Corporate / Home Office) and department, I want to know who the single highest-spending customer is.
-- Output: segment, department, customer_id, total_revenue, rank. If there are ties, show both. This will feed into
-- our personalised outreach tool."
--================================================================================================================

WITH customer_base AS(
    SELECT
        customer_segment,
        department_name,
        customer_id,
        SUM(sales) as total_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping_canceled'
    GROUP BY customer_segment, department_name, customer_id
),
    ranking AS(
        SELECT
            *,
            DENSE_RANK() OVER (
                PARTITION BY customer_segment, department_name
                ORDER BY total_revenue DESC
                ) AS rank
        FROM customer_base
    )
SELECT
    customer_segment,
    department_name,
    customer_id,
    total_revenue,
    rank
FROM ranking
WHERE rank = 1
ORDER BY rank;