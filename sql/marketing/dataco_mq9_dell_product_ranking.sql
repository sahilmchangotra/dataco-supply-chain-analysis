--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Q9 -  bol product & assortment operations:
-- "Our Dell account manager is asking why Dell Laptop visibility is low on our platform. I need to understand
-- how Dell ranks within the broader tech and electronics space — are they being crowded out by Garmin, GoPro,
-- Fitbit and other devices?
-- Use these categories: Consumer Electronics, Electronics, Computers.
-- For each product show me:
--
-- Product name
-- Category
-- Total revenue
-- Total orders
-- Market share % across all three categories combined
-- Rank by revenue descending
-- Revenue gap to the #1 ranked product
-- Brand flag (Dell, Garmin, GoPro, Fitbit, Nike Tech, Other)
--===============================================================================================================

WITH product_base AS(
    SELECT
        product_name,
        category_name,
        order_id,
        CASE
                WHEN product_name ILIKE '%DELL%' THEN 'Dell'
                WHEN product_name ILIKE '%Garmin%'  THEN 'Garmin'
                WHEN product_name ILIKE '%GoPro%'   THEN 'GoPro'
                WHEN product_name ILIKE '%Fitbit%'  THEN 'Fitbit'
                ELSE 'Other'
            END AS brand_flag,
        SUM(sales) AS order_revenue

    FROM orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
        AND category_name IN ('Consumer Electronics', 'Electronics', 'Computers')
    GROUP BY product_name, category_name, order_id


),
    product_agg AS(
        SELECT
            product_name,
            category_name,
            brand_flag,
            SUM(order_revenue) AS total_revenue,
            COUNT(order_id) AS total_orders
        FROM product_base
        GROUP BY product_name, category_name, brand_flag
    )
SELECT
    *,
    ROUND(total_revenue * 100.0 / NULLIF(SUM(total_revenue) OVER(), 0), 2) AS market_share_pct,
    RANK() OVER (ORDER BY total_revenue DESC) AS rank,
    FIRST_VALUE(total_revenue) OVER (ORDER BY total_revenue DESC) - total_revenue AS gap_to_leader
FROM product_agg
ORDER BY rank;