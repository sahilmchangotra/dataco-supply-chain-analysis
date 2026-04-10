--================================================================================================================
-- Introducing - Mixed Practice Block:
-- 📧 MX1 — bol performance marketing:
--
-- "I want to see which products are the most and least profitable within each department. Rank all products
-- by profit ratio within their department — highest profit ratio = rank 1. Flag the #1 ranked product as 'Hero'
-- and the last ranked product as 'Retire'. Show only rank 1 and last rank per department."
--================================================================================================================

WITH product_base AS(
    SELECT
        department_name,
        product_name,
        ROUND(AVG(order_item_profit_ratio), 2) AS avg_profit_ratio,
        SUM(sales) AS total_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY product_name, department_name
    HAVING COUNT(DISTINCT order_id) >= 10
),
    ranking AS(
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY department_name
                ORDER BY avg_profit_ratio ASC
                ) AS  last_rank,
            ROW_NUMBER() OVER (
                PARTITION BY department_name
                ORDER BY avg_profit_ratio DESC
                ) AS top_rank
        FROM product_base
    ),
    flagging AS(
        SELECT
            *,
            CASE
                WHEN top_rank = 1 THEN 'Hero'
                WHEN last_rank = 1 THEN 'Retire'
                END AS flag
        FROM ranking
    )
SELECT
    department_name,
    product_name,
    avg_profit_ratio,
    total_revenue,
    top_rank,
    last_rank,
    flag
FROM flagging
WHERE top_rank = 1 or last_rank = 1;