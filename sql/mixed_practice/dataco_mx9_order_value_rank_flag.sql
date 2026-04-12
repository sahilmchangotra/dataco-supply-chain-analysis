--================================================================================================================
-- Introducing - Mixed Practice Block:
-- 📧 MX9 —  BOL Category Marketing:
--
-- I'm doing a customer spend trajectory analysis. For each customer, I want to rank all their orders by value — highest
-- to lowest. Then flag whether their most recent order was also their highest value order. This tells us if customers
-- are spending more over time or declining. Output: customer_id, order_id, order_value, order_date, value_rank,
-- is_best_order, most_recent_flag.
--================================================================================================================

WITH order_base AS(
    SELECT
        customer_id,
        order_id,
        SUM(sales) AS order_value,
        MAX(order_date) AS max_order_date
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY customer_id, order_id
),
    ranking AS(
        SELECT
            *,
            DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_value DESC) AS value_rank,
            FIRST_VALUE(order_id) OVER (PARTITION BY customer_id ORDER BY max_order_date DESC) AS most_recent_order_id,
            FIRST_VALUE(order_id) OVER (PARTITION BY customer_id ORDER BY order_value DESC) AS highest_value_order_id
        FROM order_base
    )
SELECT
    customer_id,
    order_id,
    order_value,
    max_order_date,
    value_rank,
    CASE
        WHEN order_id = most_recent_order_id THEN 'Most Recent'
        ELSE ''
    END AS recent_flag,
    CASE
        WHEN most_recent_order_id = highest_value_order_id THEN 'Yes - Peak Spender'
        ELSE 'No - Declining'
    END AS is_best_order
FROm ranking
WHERE value_rank = 1;