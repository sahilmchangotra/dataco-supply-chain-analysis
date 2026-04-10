--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ15 — Flipkart Data Engineering Interview:
--
-- This is a classic interview question we use to test SQL fundamentals. Find the median order value per customer
-- segment — but you cannot use PERCENTILE_CONT or PERCENTILE_DISC. You must calculate the median manually using
-- ROW_NUMBER and COUNT. Output: customer_segment, median_order_value.
--================================================================================================================
WITH order_base AS(
    SELECT
        customer_segment,
        order_id,
        SUM(sales) AS order_value
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY customer_segment, order_id
),
    ranking AS(
        SELECT
            customer_segment,
            order_value,
            ROW_NUMBER() OVER (
                PARTITION BY customer_segment
                ORDER BY order_value
                ) AS rn,
            COUNT(*) OVER (PARTITION BY customer_segment) AS total_rows
        FROM order_base
    )
        SELECT
            customer_segment,
            AVG(order_value) AS median_order_value
        FROM ranking
        WHERE rn IN (
            FLOOR((total_rows + 1) / 2.0),
            CEIL((total_rows + 1) / 2.0)
            )
        GROUP BY customer_segment
        ORDER BY customer_segment;