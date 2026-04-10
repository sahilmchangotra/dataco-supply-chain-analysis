--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ8 — Amazon Seller Analytics:
--
-- "I'm doing a category health review. I need to know which products were in the top 10 by revenue in 2016 but fell
-- OUT of the top 10 in 2017. These are products that were strong performers but may be declining — I want to flag
-- them for the category team.

-- Output: product_name, 2016 revenue, 2016 rank, 2017 revenue (if any), 2017 rank (if any).
-- Mark clearly if they dropped out."
--================================================================================================================

WITH product_base_2016 AS(
    SELECT
        product_name,
        SUM(sales) AS total_revenue_2016
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
        AND EXTRACT(YEAR FROM order_date) = 2016
    GROUP BY product_name
),
    product_base_2017 AS(
        SELECT
            product_name,
            SUM(sales) AS total_revenue_2017
        FROM supply_chain.orders
        WHERE order_status IN ('CLOSED','COMPLETE')
            AND delivery_status != 'Shipping canceled'
            AND EXTRACT(YEAR FROM order_date) = 2017
        GROUP BY product_name
    ),
    ranking_2016 AS(
        SELECT
            product_name,
            total_revenue_2016,
            DENSE_RANK() OVER (ORDER BY total_revenue_2016 DESC) AS rank_2016
        FROM product_base_2016
    ),
    ranking_2017 AS(
        SELECT
            product_name,
            total_revenue_2017,
            DENSE_RANK() OVER (ORDER BY total_revenue_2017 DESC) AS rank_2017
        FROM product_base_2017
    )
        SELECT
            n.product_name,
            n.total_revenue_2017,
            o.total_revenue_2016,
            n.rank_2017,
            o.rank_2016,
            CASE
                WHEN n.rank_2017 IS NULL THEN 'No sales in 2017'
                WHEN n.rank_2017 > 10 THEN 'Dropped out - rank' || n.rank_2017
            END AS status_flag
        FROM ranking_2016 o
        LEFT JOIN ranking_2017 n
            ON o.product_name = n.product_name
        WHERE o.rank_2016 <=10
        AND (n.rank_2017 IS NULL OR n.rank_2017 > 10);