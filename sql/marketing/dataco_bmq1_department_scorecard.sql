--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Bonus Question 1 -  bol category marketing:
-- "I need to understand which product categories are our top revenue drivers and whether they're growing or
-- declining. For each department show me a performance scorecard — revenue, orders, avg order value, profit ratio,
-- and crucially — is this department in the top 25% or bottom 25% of revenue performers?
-- For each department show me:
--
-- Department name
-- Total revenue
-- Total orders
-- Avg order value
-- Avg profit ratio
-- Revenue tier (Top 25% / Mid 50% / Bottom 25%) using NTILE
-- Rank by revenue descending
--
-- Same filters as always."
--===============================================================================================================

WITH product_base AS(
    SELECT
        department_name,
        SUM(sales) AS total_revenue,
        COUNT(order_id) AS total_orders,
        ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS avg_order_value,
        ROUND(AVG(order_item_profit_ratio), 2) AS avg_profit_ratio
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY department_name
),
    quantile_range AS(
        SELECT
            *,
            NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_ntile
        FROM product_base
    )
SELECT
    department_name,
    total_revenue,
    total_orders,
    avg_order_value,
    avg_profit_ratio,
    RANK() OVER (ORDER BY total_revenue DESC) AS rank,
    CASE
        WHEN revenue_ntile = 1 THEN 'Top 25%'
        WHEN revenue_ntile BETWEEN 2 AND 3 THEN 'Mid 50%'
        WHEN revenue_ntile = 4 THEN 'Bottom 25%'
    END AS revenue_tier
FROM quantile_range
ORDER BY rank;