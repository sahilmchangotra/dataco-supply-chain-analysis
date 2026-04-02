--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Q2 - bol performance marketing:
-- "Our pricing team wants to run a discount simulation. The idea is simple — identify which product categories
-- are currently below the average discount rate, and simulate what happens if we give them an extra
-- 10% discount on top of what they already have.
-- I need two views side by side using UNION ALL:
--
-- Part 1: Current state — all categories with their avg discount rate, avg profit ratio, and total revenue
-- Part 2: Simulated state — same categories but only the below-average ones, with discount rate + 10%, and projected
-- revenue after applying the extra discount
--
-- For each part show me:
--
-- Scenario label ('Current' or 'Simulated')
-- Category name
-- Avg discount rate %
-- Avg profit ratio
-- Total revenue
-- Below average flag (Yes/No)
--
-- Same filters as always."
--===============================================================================================================


WITH product_base AS(
    SELECT
        category_name,
        ROUND(AVG(order_item_discount_rate)::NUMERIC, 2) AS avg_discount_rate,
        ROUND(AVG(order_item_profit_ratio)::NUMERIC, 2) AS avg_profit_ratio,
        SUM(sales) AS total_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY category_name
),
    current_state_scenario AS (
        SELECT
            'Current' AS scenario_label,
            category_name AS category_name,
            avg_discount_rate AS avg_discount_rate,
            avg_profit_ratio AS avg_profit_ratio,
            total_revenue AS total_revenue,
            CASE WHEN avg_discount_rate < AVG(avg_discount_rate) OVER () THEN 'Yes' ELSE 'No' END AS below_average_flag
        FROM product_base
    ),
    simulated_state_scenario AS(
        SELECT
            'Simulated' AS scenario_label,
            category_name AS category_name,
            avg_discount_rate + 0.1 AS avg_discount_rate,
            avg_profit_ratio AS avg_profit_ratio,
            total_revenue,
            total_revenue * (1 - (avg_discount_rate + 0.10)) AS projected_revenue,
            'Yes' AS below_average_flag
        FROM product_base
        WHERE avg_discount_rate < (SELECT AVG(avg_discount_rate) FROM product_base)
    )
SELECT
    scenario_label,
    category_name,
    avg_discount_rate,
    avg_profit_ratio,
    total_revenue,
    NULL::NUMERIC AS projected_revenue,
    below_average_flag
FROM current_state_scenario

UNION ALL

SELECT
    scenario_label,
    category_name,
    avg_discount_rate,
    avg_profit_ratio,
    total_revenue,
    projected_revenue,
    below_average_flag
FROM simulated_state_scenario
ORDER BY scenario_label DESC, category_name;