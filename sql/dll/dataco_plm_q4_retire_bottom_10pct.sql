--================================================================================================================
-- INTRODUCING : Product Life Management
-- ✅ Q4 - BOL product & assortment operations:
-- "I need to make a tough call. We want to retire the bottom 10% of products by revenue — products that are dragging
-- the portfolio without contributing meaningfully. Before I present this to leadership I need to know the financial impact.
-- Simulate retiring the bottom 10% of products by current revenue. Show me:
--
-- How many products would be retired
-- Their total revenue
-- Their revenue as % of total portfolio
-- Their avg profit ratio
-- Their avg discount rate
-- Compare: remaining portfolio revenue vs retired revenue
-- Top 5 products that would be retired (so leadership can sanity check)
--
-- Use the last 12 months of data. Same filters as always."
--================================================================================================================

WITH ref_date AS(
    SELECT
        MAX(order_date) AS max_date
    FROM supply_chain.orders
),
    product_revenue AS(
        SELECT
            product_name,
            department_name,
            COUNT(DISTINCT order_id) AS total_orders,
            SUM(sales) AS current_revenue,
            ROUND(AVG(order_item_profit_ratio), 2) AS avg_profit_ratio,
            ROUND(AVG(order_item_discount_rate), 2) AS avg_discount_rate
        FROM supply_chain.orders, ref_date
        WHERE order_status IN ('CLOSED', 'COMPLETE')
            AND delivery_status != 'Shipping canceled'
            AND order_date >= max_date - INTERVAL '12 months'
        GROUP BY product_name, department_name
    ),
    deciled AS(
        SELECT
            *,
            NTILE(10) OVER (ORDER BY current_revenue ASC) AS revenue_decile
        FROM product_revenue
    ),
    summary AS (
        SELECT
            CASE
                WHEN revenue_decile = 1 THEN 'Retired' ELSE 'Remaining' END AS portfolio_group,
            COUNT(DISTINCT product_name) AS total_products,
            ROUND(SUM(current_revenue), 2) AS total_revenue,
            ROUND(AVG(avg_profit_ratio), 2) AS avg_profit_ratio,
            ROUND(AVG(avg_discount_rate), 2) AS avg_discount_rate,
            ROUND(SUM(current_revenue) * 100.0 /
                  NULLIF(SUM(SUM(current_revenue)) OVER (), 0), 2) AS revenue_share_pct
        FROM deciled
        GROUP BY CASE
                WHEN revenue_decile = 1 THEN 'Retired' ELSE 'Remaining' END
    )
SELECT
    *
FROM summary
ORDER BY portfolio_group DESC;

WITH ref_date AS(
    SELECT
        MAX(order_date) AS max_date
    FROM supply_chain.orders
),
    product_revenue AS(
        SELECT
            product_name,
            department_name,
            COUNT(DISTINCT order_id) AS total_orders,
            SUM(sales) AS current_revenue,
            ROUND(AVG(order_item_profit_ratio), 2) AS avg_profit_ratio,
            ROUND(AVG(order_item_discount_rate), 2) AS avg_discount_rate
        FROM supply_chain.orders, ref_date
        WHERE order_status IN ('CLOSED', 'COMPLETE')
            AND delivery_status != 'Shipping canceled'
            AND order_date >= max_date - INTERVAL '12 months'
        GROUP BY product_name, department_name
    ),
    deciled AS(
        SELECT
            *,
            NTILE(10) OVER (ORDER BY current_revenue ASC) AS revenue_decile
        FROM product_revenue
    ),
    summary AS (
        SELECT
            CASE
                WHEN revenue_decile = 1 THEN 'Retired' ELSE 'Remaining' END AS portfolio_group,
            COUNT(DISTINCT product_name) AS total_products,
            ROUND(SUM(current_revenue), 2) AS total_revenue,
            ROUND(AVG(avg_profit_ratio), 2) AS avg_profit_ratio,
            ROUND(AVG(avg_discount_rate), 2) AS avg_discount_rate,
            ROUND(SUM(current_revenue) * 100.0 /
                  NULLIF(SUM(SUM(current_revenue)) OVER (), 0), 2) AS revenue_share_pct
        FROM deciled
        GROUP BY CASE
                WHEN revenue_decile = 1 THEN 'Retired' ELSE 'Remaining' END
    )
SELECT
    product_name,
    department_name,
    current_revenue,
    avg_profit_ratio,
    revenue_decile
FROM deciled
WHERE revenue_decile = 1
ORDER BY current_revenue DESC
LIMIT 5;