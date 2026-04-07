--================================================================================================================
-- INTRODUCING : Product Life Management
-- ✅ Q2 -   Revenue Analytics:
-- PLM Q1 gave us the current snapshot. Now I need to see the transition — which products moved from Growth to Decline?
-- These are the most dangerous products in our portfolio — they were growing, now they're falling. I need to catch them early.
-- Compare two consecutive 12-month periods:
--
-- Period 1: 24–12 months before max date (the 'before' period)
-- Period 2: last 12 months (the 'after' period)
--
-- A product is 'Growth → Decline' if:
--
-- Period 1 YoY growth was positive (> 0%)
-- Period 2 YoY growth is negative (< -10%)
--
-- For each flagged product show me:
--
-- Product name
-- Department
-- Period 1 revenue
-- Period 2 revenue
-- Period 1 YoY %
-- Period 2 YoY %
-- Revenue change between periods
-- Transition flag: 'Growth → Decline', 'Decline → Growth', 'Consistently Declining', 'Consistently Growing', 'Stable'
-- Rank by revenue drop descending"
--================================================================================================================

WITH ref_date AS(
    SELECT
        MAX(order_date) AS max_date
    FROM supply_chain.orders
),
    earliest_period AS(
        SELECT
            product_name,
            department_name,
            SUM(sales) AS earliest_revenue
        FROM supply_chain.orders, ref_date
        WHERE order_status IN ('CLOSED', 'COMPLETE')
            AND delivery_status != 'Shipping canceled'
            AND order_date >= max_date - INTERVAL '36 months'
            AND order_date < max_date - INTERVAL '24 months'
        GROUP BY product_name, department_name
    ),
    period_1 AS (
        SELECT
            product_name,
            department_name,
            SUM(sales) AS period_1_revenue
        FROM supply_chain.orders, ref_date
        WHERE order_status IN ('CLOSED', 'COMPLETE')
            AND delivery_status != 'Shipping canceled'
            AND order_date >= max_date - INTERVAL '24 months'
            AND order_date < max_date - INTERVAL '12 months'
        GROUP BY product_name, department_name
    ),
    period_2 AS(
        SELECT
            product_name,
            department_name,
            SUM(sales) AS period_2_revenue
        FROM supply_chain.orders, ref_date
        WHERE order_status IN ('CLOSED', 'COMPLETE')
            AND delivery_status != 'Shipping canceled'
            AND order_date >= max_date - INTERVAL '12 months'
        GROUP BY product_name, department_name
    ),
    yoy AS(
        SELECT
            ep.product_name,
            ep.department_name,
            p1.period_1_revenue,
            p2.period_2_revenue,
            ROUND((p1.period_1_revenue - ep.earliest_revenue) * 100.0 /
                    NULLIF(ep.earliest_revenue, 0), 2) AS p1_yoy,
            ROUND((p2.period_2_revenue - p1.period_1_revenue) * 100.0 /
                    NULLIF(p1.period_1_revenue, 0), 2) AS p2_yoy,
            (p1.period_1_revenue - p2.period_2_revenue) AS period_revenue_change
        FROM earliest_period ep
        LEFT JOIN period_1 p1
            ON ep.product_name = p1.product_name
            AND ep.department_name = p1.department_name
        LEFT JOIN period_2 p2
            ON ep.product_name = p2.product_name
            AND ep.department_name = p2.department_name
    )
SELECT
    product_name,
    department_name,
    period_1_revenue,
    period_2_revenue,
    p1_yoy,
    p2_yoy,
    period_revenue_change,
    CASE
        WHEN p1_yoy > 0 AND p2_yoy < - 10 THEN 'Growth -> Decline'
        WHEN p1_yoy < -10  AND p2_yoy > 0    THEN 'Decline → Growth'
        WHEN p1_yoy < -10  AND p2_yoy < -10  THEN 'Consistently Declining'
        WHEN p1_yoy > 0    AND p2_yoy > 0    THEN 'Consistently Growing'
        ELSE 'Stable'
    END AS transition_flag,
    RANK () OVER (ORDER BY period_revenue_change DESC) AS rank
FROM yoy
ORDER BY rank;