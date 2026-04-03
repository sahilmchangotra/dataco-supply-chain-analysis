--================================================================================================================
-- INTRODUCING : Sales & Marketing Integrated Questions
-- ✅ Q2 -  Revenue Analytics:
--"I need to understand repeat purchase behaviour. Specifically — which customers came back within 90 days of
-- their first order, and how much revenue did they generate in that window? This tells us the true value of a retained
-- customer vs a one-time buyer.
-- For each customer show me:
--
-- Customer ID
-- First order date
-- Second order date (if exists within 90 days)
-- Days between first and second order
-- First order revenue
-- Total revenue within 90 days of first order
-- Repeat flag (did they order again within 90 days?)
--
-- Then summarise:
--
-- Total customers
-- Repeat customers (ordered again within 90 days)
-- Repeat rate %
-- Avg revenue — repeat customers vs one-time customers
-- Avg days to second order (for repeat customers only)"
--================================================================================================================

WITH order_base AS(
    SELECT
        customer_id,
        order_id,
        MIN(order_date) AS order_date,
        SUM(sales) AS order_revenue
    FROM orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY customer_id, order_id
),
    with_lead AS(
        SELECT
            customer_id,
            order_id,
            order_date,
            order_revenue,
            MIN(order_date) OVER (PARTITION BY customer_id) AS first_order_date,
            LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_date
        FROM order_base
    ),
    window_90d AS(
        SELECT
            *
        FROM with_lead
        WHERE order_date <= first_order_date + INTERVAL '90 days'
    ),
    customer_summary AS(
        SELECT
            customer_id,
            first_order_date,
            MIN(CASE WHEN next_order_date::DATE <= first_order_date::DATE + INTERVAL '90 days'
                    THEN next_order_date END) AS second_order_date,
            MIN(CASE WHEN next_order_date::DATE <= first_order_date::DATE + INTERVAL '90 days'
                    THEN (next_order_date::DATE - first_order_date::DATE) END) AS days_to_second_order,
            SUM(CASE WHEN order_date::DATE = first_order_date::DATE THEN order_revenue ELSE 0 END) AS first_order_revenue,
            SUM(order_revenue) AS total_90d_revenue,
            CASE WHEN MIN(CASE WHEN next_order_date::DATE <= first_order_date::DATE + INTERVAL '90 days'
                      THEN next_order_date END) IS NOT NULL THEN 1 ELSE 0 END AS repeat_flag
        FROM window_90d
        GROUP BY customer_id, first_order_date
    ),
    summary_check AS(
        SELECT
    customer_id,
    first_order_date,
    second_order_date,
    days_to_second_order,
    first_order_revenue,
    total_90d_revenue,
    repeat_flag
FROM customer_summary
    )
-- Summary statistics
SELECT
    COUNT(customer_id)                                          AS total_customers,
    SUM(repeat_flag)                                            AS repeat_customers,
    ROUND(SUM(repeat_flag) * 100.0 /
          NULLIF(COUNT(customer_id), 0), 2)                     AS repeat_rate_pct,
    ROUND(AVG(CASE WHEN repeat_flag = 1
              THEN total_90d_revenue END), 2)                   AS avg_revenue_repeat,
    ROUND(AVG(CASE WHEN repeat_flag = 0
              THEN total_90d_revenue END), 2)                   AS avg_revenue_one_time,
    ROUND(AVG(CASE WHEN repeat_flag = 1
              THEN days_to_second_order END), 2)                AS avg_days_to_repeat
FROM customer_summary;