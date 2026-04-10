--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ5 — Swiggy Data Analyst Interview:
--
-- "We want to understand which products are most popular in each city. For each city, find the top 3 most ordered
-- products by order count. If there are ties, include all tied products at the same rank.
-- Show me:
--
-- Order city
-- Product name
-- Total orders
-- Total revenue
-- Rank within city (1, 2, or 3)
--
-- Only show cities with at least 100 orders total. Show only rank 1, 2, and 3."
--================================================================================================================
WITH order_base AS(
    SELECT
        order_city,
        product_name,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(sales) AS order_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY order_city, product_name
),
    city_totals AS(
        SELECT
            order_city,
            SUM(order_count) AS city_total_orders
        FROM order_base
        GROUP BY order_city
        HAVING SUM(order_count) >= 100
    ),
    ranked AS(
        SELECT
            ob.order_city,
            ob.product_name,
            ob.order_count,
            ob.order_revenue,
            DENSE_RANK() OVER(
                PARTITION BY ob.order_city
                ORDER BY ob.order_count DESC
                ) AS rank
        FROM order_base ob
        JOIN city_totals oc
            ON ob.order_city = oc.order_city
    )
SELECT
    order_city,
    product_name,
    order_count,
    order_revenue,
    rank
FROM ranked
WHERE rank <= 3
ORDER BY order_city, rank;