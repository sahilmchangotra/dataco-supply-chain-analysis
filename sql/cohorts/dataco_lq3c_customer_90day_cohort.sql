--================================================================================================================
-- INTRODUCING : Cohort Questions
-- ✅ Q2 -   JET SODA Logistics Ops:
-- I want to understand repeat purchase behaviour as a cohort. For each month, track the customers who placed their
-- first ever order — then measure what % of them placed a second order within 90 days.
-- This is a true cohort analysis — group customers by their acquisition month, then track their 90-day repeat behaviour.
-- For each acquisition month show me:
--
-- Acquisition month
-- New customers acquired
-- Customers who repeated within 90 days
-- 90-day repeat rate %
-- Avg days to second order
-- Avg first order revenue
-- Avg total 90-day revenue
--================================================================================================================

WITH customer_base AS(
    SELECT
        order_id,
        customer_id,
        MIN(order_date) AS order_date,
        SUM(sales) AS order_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY order_id, customer_id
),
    with_flags AS(

        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_rank
        FROM customer_base
    ),
    new_customers AS(
        SELECT
            customer_id,
            order_date AS first_order_date,
            DATE_TRUNC('month',order_date) AS acquisition_month,
            order_revenue AS first_order_revenue
        FROM with_flags
        WHERE order_rank = 1
    ),
    within_90d AS(
        SELECT
            nc.customer_id,
            nc.first_order_date,
            nc.acquisition_month,
            nc.first_order_revenue,
            ob.order_id,
            ob.order_date,
            ob.order_revenue,
            ob.order_rank
        FROM new_customers nc
        JOIN with_flags ob
            ON nc.customer_id = ob.customer_id
            AND ob.order_date <= nc.first_order_date + INTERVAL '90 days'

    ),
    customer_summary AS(
        SELECT
            customer_id,
            acquisition_month,
            first_order_revenue,
            SUM(order_revenue) AS total_90d_revenue,
            COUNT(DISTINCT order_id) AS orders_in_90d,
            MIN(CASE WHEN order_rank > 1 THEN order_date END) AS second_order_date,
            MIN(CASE WHEN order_rank > 1 THEN
                (order_date::DATE - first_order_date::DATE) END) AS days_to_second_order,
            CASE WHEN COUNT(DISTINCT order_id) > 1
                    THEN 1 ELSE 0 END AS repeat_flag
        FROM within_90d
        GROUP BY customer_id, acquisition_month, first_order_revenue
    ),
    cohort_summary AS(
SELECT
    TO_CHAR(acquisition_month, 'YYYY-MM') AS acquisition_month,
    COUNT(customer_id) AS new_customers,
    SUM(repeat_flag) AS repeat_customers,
    ROUND(SUM(repeat_flag) * 100.0 /
            NULLIF(COUNT(customer_id),0), 2) AS repeat_rate_pct,
    ROUND(AVG(days_to_second_order), 2) AS avg_days_to_second,
    ROUND(AVG(first_order_revenue), 2) AS avg_first_order_revenue,
    ROUND(AVG(total_90d_revenue), 2) AS avg_90d_revenue
FROM customer_summary
GROUP BY acquisition_month
 )
SELECT
    *
FROM cohort_summary
ORDER BY acquisition_month;