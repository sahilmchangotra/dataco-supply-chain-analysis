--==================================================================================================
--"Same question but keep it simple. For each customer, show me their orders in sequence
-- using LEAD — the current order date, the next order date, and how many days between them.
-- Flag if the next order came within 90 days. Then summarise the repeat rate and avg days to return."
--==================================================================================================

WITH order_base AS(
    SELECT
        customer_id,
        order_id,
        MIN(order_date) AS order_date,
        SUM(sales) AS order_revenue
    FROM supply_chain.orders
WHERE order_status IN ('CLOSED', 'COMPLETE')
  AND delivery_status != 'Shipping canceled'
GROUP BY customer_id, order_id
),
    order_lead AS(
        SELECT
            customer_id,
            order_id,
            order_date,
            order_revenue,
            LEAD(order_date) OVER (
                PARTITION BY customer_id
                ORDER BY order_date
                ) AS next_order_date,
            (LEAD(order_date::DATE) OVER (
                PARTITION BY customer_id
                ORDER BY order_date) - order_date::DATE ) AS days_to_next_order
        FROM order_base
    )
SELECT
    customer_id,
    order_date,
    next_order_date,
    days_to_next_order,
    CASE
        WHEN days_to_next_order IS NULL THEN 'No repeat'
        WHEN days_to_next_order <= 90  THEN 'Repeat ≤ 90 days'
        ELSE 'Repeat > 90 days'
    END AS repeat_flag
FROM order_lead
ORDER BY days_to_next_order ASC NULLS LAST
LIMIT 20;

WITH order_base AS(
    SELECT
        customer_id,
        order_id,
        MIN(order_date) AS order_date,
        SUM(sales) AS order_revenue
    FROM supply_chain.orders
WHERE order_status IN ('CLOSED', 'COMPLETE')
  AND delivery_status != 'Shipping canceled'
GROUP BY customer_id, order_id
),
    order_lead AS(
        SELECT
            customer_id,
            order_id,
            order_date,
            order_revenue,
            LEAD(order_date) OVER (
                PARTITION BY customer_id
                ORDER BY order_date
                ) AS next_order_date,
            (LEAD(order_date::DATE) OVER (
                PARTITION BY customer_id
                ORDER BY order_date) - order_date::DATE ) AS days_to_next_order
        FROM order_base
    )
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN days_to_next_order <= 90
            THEN customer_id END) AS repeat_customers,
     ROUND(COUNT(DISTINCT CASE WHEN days_to_next_order <= 90
        THEN customer_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT customer_id), 0), 2)               AS repeat_rate_pct,
    ROUND(AVG(CASE WHEN days_to_next_order <= 90
        THEN days_to_next_order END), 2)                         AS avg_days_to_repeat
FROM order_lead;