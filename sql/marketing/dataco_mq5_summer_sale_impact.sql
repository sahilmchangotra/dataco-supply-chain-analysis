--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Q5 -  bol category marketing:
-- "Every year we run a summer sale from June through August. I need to know whether it actually moves the needle
-- on revenue and profit compared to the rest of the year. I want a clean side-by-side comparison.
-- For each period show me:
--
-- Period label ('Summer Sale' or 'Rest of Year')
-- Total orders
-- Total revenue
-- Avg revenue per order
-- Total profit (sales x profit ratio)
-- Avg profit ratio
-- Late delivery rate %
--
-- Use UNION ALL — one row per period. Same filters as always."
--===============================================================================================================

SELECT
    period_label,
    total_orders,
    total_revenue,
    avg_revenue_per_order,
    avg_profit_ratio,
    total_profit,
    late_delivery_rate_pct
FROM
    (
    SELECT
        CASE
            WHEN EXTRACT(MONTH FROM order_date) IN (6, 7, 8) THEN 'Summer Sale'
            ELSE 'Rest of Year'
        END AS period_label,
        COUNT(order_id) AS total_orders,
        SUM(sales) AS total_revenue,
        ROUND(SUM(sales) / NULLIF(COUNT(order_id), 0), 2) AS avg_revenue_per_order,
        ROUND(AVG(order_item_profit_ratio), 2) AS avg_profit_ratio,
        ROUND(SUM(sales * order_item_profit_ratio), 2) AS total_profit,
        ROUND(SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(COUNT(order_id),0), 2) AS late_delivery_rate_pct
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY CASE
            WHEN EXTRACT(MONTH FROM order_date) IN (6, 7, 8) THEN 'Summer Sale'
            ELSE 'Rest of Year' END)  t
ORDER BY period_label;