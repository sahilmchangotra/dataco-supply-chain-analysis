--================================================================================================================
-- INTRODUCING : Product Life Management
-- ✅ Q1 -   BOL category marketing:
--I want to classify each product into a lifecycle stage based on its revenue trend and order volume. Use the last 12
-- months of data available in the dataset. A product is:

-- Introduction: low volume (bottom 25% orders) AND low revenue (bottom 25%)
-- Growth: revenue growing YoY AND above median order volume
-- Maturity: high volume (top 25% orders) AND stable revenue (YoY change within ±10%)
-- Decline: revenue declining YoY AND below median order volume
--
-- For each product show me:
--
-- Product name
-- Department
-- Total orders
-- Total revenue
-- YoY revenue change %
-- Order volume tier (NTILE 4)
-- Revenue tier (NTILE 4)
-- Lifecycle stage
-- Rank by revenue descending within each stage
--================================================================================================================

-- NOTE: Growth and Maturity stages return 0 products due to DataCo Oct 2017 volume collapse — last 12 months revenue
-- universally lower than prior 12 months. Lifecycle model is correct — dataset limitation prevents Growth/Maturity signals.

WITH ref_date AS(
    SELECT
        MAX(order_date) AS max_date
    FROM supply_chain.orders

),
    current_period AS(
        SELECT
            product_name,
            department_name,
            COUNT(DISTINCT order_id) AS total_orders,
            SUM(sales) AS current_revenue
        FROM supply_chain.orders, ref_date
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
        AND order_date >= max_date - INTERVAL '12 months'
    GROUP BY product_name, department_name
    ),
    prior_period AS(
        SELECT
            product_name,
            department_name,
            SUM(sales) AS prior_revenue
        FROM supply_chain.orders, ref_date
        WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
        AND order_date >= max_date - INTERVAL '24 months'
        AND order_date < max_date - INTERVAL '12 months'
    GROUP BY product_name, department_name
    ),
    yoy AS (
        SELECT
            c.product_name,
            c.department_name,
            c.total_orders,
            c.current_revenue,
            p.prior_revenue,
            ROUND((c.current_revenue - p.prior_revenue) * 100.0 /
                  NULLIF(p.prior_revenue, 0), 2) AS yoy_growth_pct
        FROM current_period c
        LEFT JOIN prior_period p
            ON c.product_name = p.product_name
            AND c.department_name = p.department_name
    ),
    quantiled AS(
        SELECT
            *,

            NTILE(4) OVER (ORDER BY total_orders) AS order_tier,
            NTILE(4) OVER (ORDER BY current_revenue) AS revenue_tier
        FROM yoy
    ),
    lifecycle AS(
        SELECT
            *,
            CASE
                WHEN order_tier = 1 AND revenue_tier = 1 THEN 'Introduction'
                WHEN yoy_growth_pct > 10 AND order_tier >= 2 THEN 'Growth'
                WHEN order_tier = 4 AND ABS(yoy_growth_pct) <= 10 THEN 'Maturity'
                WHEN yoy_growth_pct < -10 AND order_tier <= 2 THEN 'Decline'
                ELSE 'Mixed'
            END AS lifecycle_stage,
            RANK() OVER (ORDER BY current_revenue DESC) AS rank
        FROM quantiled
    )
SELECT
    product_name,
    department_name,
    total_orders,
    current_revenue,
    prior_revenue,
    yoy_growth_pct,
    order_tier,
    revenue_tier,
    lifecycle_stage,
    rank
FROM lifecycle
ORDER BY rank;