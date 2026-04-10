--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ13 — Uber Eats Revenue Analytics:
--
-- I need a running revenue total that resets at the start of every month. For each day, show me the order date,
-- daily revenue, and the cumulative revenue from the start of that month up to and including that day. This helps
-- our finance team track how we're tracking against monthly revenue targets in real time. Output: order_date,
-- daily_revenue, running_monthly_total.
--================================================================================================================

WITH order_base AS(
    SELECT
        order_date::DATE AS order_date,
        SUM(sales) AS daily_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY order_date::DATE
),
    running_revenue AS(
        SELECT
            *,
            SUM(daily_revenue) OVER (
                PARTITION BY DATE_TRUNC('month',order_date)
                ORDER BY order_date
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS running_monthly_total
        FROM order_base
    )
SELECT
    order_date,
    daily_revenue,
    running_monthly_total
FROM running_revenue
ORDER BY order_date;