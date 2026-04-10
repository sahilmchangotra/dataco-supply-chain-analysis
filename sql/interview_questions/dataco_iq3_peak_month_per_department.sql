--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ3 — Zomato Data Analyst Interview:
--
-- "We want to understand which month each department had its peak order volume — not just the overall best month,
-- but the best month specifically for each department. If two months tie for the same department, show both.
-- Return department name, best month, order count, and rank within department."
--================================================================================================================

WITH order_base AS(
    SELECT
        department_name,
        DATE_TRUNC('month', order_date) AS order_month,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(sales) AS order_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY department_name, DATE_TRUNC('month', order_date)
),
    agg AS(
        SELECT
    department_name,
    TO_CHAR(order_month, 'YYYY-MM-DD') AS order_month,
    order_count,
    order_revenue,
    DENSE_RANK() OVER (PARTITION BY department_name
        ORDER BY order_count DESC) AS rank
FROM order_base
    )

SELECT
    *
FROM agg
WHERE rank = 1
order by department_name;