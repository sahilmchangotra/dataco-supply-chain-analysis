--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Q8 -  bol performance marketing:
-- "Our team has been debating whether Corporate and Consumer segments have meaningfully different revenue per order.
-- I need a proper statistical test — not just averages. Run a t-test comparing revenue per order between Corporate
-- and Consumer segments. Tell me if the difference is statistically significant.
-- Show me:
--
-- Both segment names
-- Avg revenue per order per segment
-- Standard deviation
-- Sample size (n)
-- T-score
-- Whether the result is statistically significant (|t| > 1.96 = significant at 95% confidence)
--
-- Same filters as always."
--===============================================================================================================

WITH order_base AS(
    SELECT
        customer_segment,
        order_id,
        SUM(sales) AS order_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
        AND customer_segment IN ('Consumer','Corporate')
    GROUP BY customer_segment, order_id
),
    corporate_stats AS(
        SELECT
            customer_segment AS corporate,
            AVG(order_revenue) AS avg_revenue,
            STDDEV(order_revenue) AS std_dev,
            COUNT(order_id) AS n
        FROM order_base
        WHERE customer_segment = 'Corporate'
        GROUP BY customer_segment
    ),
    consumer_stats AS(
        SELECT
            customer_segment AS consumer,
            AVG(order_revenue) AS avg_revenue,
            STDDEV(order_revenue) AS std_dev,
            COUNT(order_id) AS n
        FROM order_base
        WHERE customer_segment = 'Consumer'
        GROUP BY customer_segment
    ),
    ttest AS(
SELECT
    ROUND(corp.avg_revenue::NUMERIC, 2) AS avg_revenue_corp,
    ROUND(cons.avg_revenue::NUMERIC, 2) AS avg_revenue_cons,
    ROUND(corp.std_dev::NUMERIC, 2) AS stddev_corp,
    ROUND(cons.std_dev::NUMERIC, 2) AS stddev_cons,
    corp.n AS corp_sample_size,
    cons.n AS cons_sample_size,
    ROUND((corp.avg_revenue - cons.avg_revenue) /
    NULLIF(SQRT(
    (corp.std_dev * corp.std_dev / corp.n) +
    (cons.std_dev * cons.std_dev / cons.n)
    ), 0), 2) AS t_score
FROM corporate_stats corp
CROSS JOIN consumer_stats cons
)
SELECT
    avg_revenue_corp,
    avg_revenue_cons,
    stddev_corp,
    stddev_cons,
    corp_sample_size,
    cons_sample_size,
    t_score,
    CASE
        WHEN ABS(t_score) > 1.96 THEN 'Significant' ELSE 'Not Significant'
        END AS significance_flag
FROM ttest;