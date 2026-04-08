--================================================================================================================
-- INTRODUCING : Cohort Questions
-- ✅ Q3 - BOL category marketing:
-- I want to understand revenue retention after acquisition. For each monthly cohort of new customers, track
-- how much revenue they generate in months 1, 2 and 3 after their first order. This tells me whether customers
-- acquired in certain months are more valuable long term.
-- For each acquisition month show me:
--
-- Acquisition month
-- New customers
-- Month 0 revenue (first order month itself)
-- Month 1 revenue (1–30 days after first order)
-- Month 2 revenue (31–60 days after first order)
-- Month 3 revenue (61–90 days after first order)
-- Total 90-day revenue
-- Avg revenue per customer
--================================================================================================================

-- Memory rule:
--
-- Always ask — what is one row in the CTE I'm reading from?
-- If one row = one customer → COUNT(customer_id)
-- If one row = one order → COUNT(DISTINCT customer_id) 💪

WITH customer_base AS(
    SELECT
        customer_id,
        order_id,
        MIN(order_date) AS order_date,
        SUM(sales) AS order_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY customer_id, order_id
),
    with_flag AS(
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_rank
        FROM customer_base
    ),
    new_customers AS(
        SELECT
            customer_id,
            order_date AS first_order_date,
            DATE_TRUNC('month', order_date) AS acquisition_month
        FROM with_flag
        WHERE order_rank = 1
    ),
    within_90d AS(
        SELECT
            nc.customer_id,
            nc.first_order_date,
            nc.acquisition_month,
            ob.order_id,
            ob.order_date,
            ob.order_revenue,
            (ob.order_date::DATE - nc.first_order_date::DATE) AS days_since_first
        FROM new_customers nc
        JOIN with_flag ob
            ON nc.customer_id = ob.customer_id
            AND ob.order_date <= nc.first_order_date + INTERVAL '90 days'
    ),
    cohort_summary AS(
        SELECT
            TO_CHAR(acquisition_month,'YYYY-MM') AS acquisition_month,
            COUNT(DISTINCT customer_id) AS new_customers,
            SUM(CASE WHEN days_since_first = 0 THEN order_revenue ELSE 0 END) AS month_0_revenue,
            SUM(CASE WHEN days_since_first BETWEEN 1 AND 30 THEN order_revenue ELSE 0 END) AS month_1_revenue,
            SUM(CASE WHEN days_since_first BETWEEN 31 AND 60 THEN order_revenue ELSE 0 END) AS month_2_revenue,
            SUM(CASE WHEN days_since_first BETWEEN 61 AND 90 THEN order_revenue ELSE 0 END) AS month_3_revenue,
            SUM(order_revenue) AS total_90d_revenue,
            ROUND(AVG(order_revenue), 2) AS avg_revenue_per_customer
        FROM within_90d
        GROUP BY acquisition_month
    )
SELECT
    *
FROM cohort_summary
ORDER BY acquisition_month;