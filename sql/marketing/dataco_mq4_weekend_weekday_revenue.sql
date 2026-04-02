--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Q4 -  bol performance marketing:
-- "I want to understand whether weekends drive different revenue patterns across our customer segments. Consumer,
-- Corporate, Home Office — do they shop differently on weekends vs weekdays? And does the revenue per order change?
-- For each combination of day type and customer segment show me:
--
-- Day type (Weekday / Weekend)
-- Customer segment
-- Total orders
-- Total revenue
-- Avg revenue per order
-- Late delivery rate % (delivery experience matters for repeat purchase)
-- Revenue share % within day type (what % of weekend revenue comes from each segment?)
--
-- Same filters as always."
--===============================================================================================================

WITH revenue_base AS(
    SELECT
        CASE
            WHEN EXTRACT(DOW FROM order_date) IN (0, 6)
            THEN 'Weekend' ELSE 'Weekday'
        END AS day_type,
        customer_segment,
        order_id,
        SUM(sales) AS order_revenue,
        MAX(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS is_late
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY CASE
            WHEN EXTRACT(DOW FROM order_date) IN (0, 6)
            THEN 'Weekend' ELSE 'Weekday'
        END, customer_segment, order_id
)
SELECT
            day_type,
            customer_segment,
            SUM(order_revenue) AS total_segment_revenue,
            ROUND(AVG(order_revenue), 2)AS avg_revenue_per_orders,
            ROUND(SUM(is_late) * 100.0 /
                  NULLIF(COUNT(order_id),0), 2) AS late_delivery_rate_pct,
            ROUND(SUM(order_revenue) * 100.0 /
                  NULLIF(SUM(SUM(order_revenue)) OVER (PARTITION BY day_type), 0), 2) AS revenue_share_pct
FROM revenue_base
GROUP BY day_type, customer_segment
ORDER BY revenue_share_pct DESC;