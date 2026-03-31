--===============================================================================================================
-- INTRODUCING : LOGISTICS Practice SQL
-- ✅ Q9 - DataCo Network Planning:
-- "Our leadership keeps asking whether certain customer segments are consistently more exposed to late delivery
-- risk than others — and whether that's getting better or worse over time. I need a monthly trend broken down by
-- customer segment.
-- For each month and customer segment show me:
--
-- Month
-- Customer segment
-- Total orders
-- Late deliveries
-- Late delivery rate %
-- 3-month rolling average late rate
-- Trend flag: is the rolling rate improving, worsening, or stable vs previous month's rolling rate?
--
-- Same filters as always."
--===============================================================================================================

-- One row in my base CTE = one month + customer segment

WITH customer_base AS(
    SELECT
        TO_CHAR(order_date, 'YYYY-MM') AS month,
        customer_segment,
        COUNT(order_id) AS total_orders,
        SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS total_late_deliveries,
        ROUND(SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 /
              NULLIF(COUNT(*),0)::NUMERIC, 2) AS late_delivery_rate_pct
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM'), customer_segment
),
    rolling_average AS(
        SELECT
            *,
            ROUND(AVG(late_delivery_rate_pct) OVER (
                PARTITION BY customer_segment
                ORDER BY month
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
                )::NUMERIC, 2) AS rolling_3m_avg
        FROM customer_base
    ),
    last_rolling_average AS(
        SELECT
            *,
            LAG(rolling_3m_avg, 1) OVER (
                PARTITION BY customer_segment
                ORDER BY month
                ) AS last_month_rolling_avg
        FROM rolling_average
    ),
    flagging AS(
        SELECT
            *,
            CASE
                WHEN rolling_3m_avg > last_month_rolling_avg THEN 'Worsening'
                WHEN rolling_3m_avg < last_month_rolling_avg THEN 'Improving'
                WHEN rolling_3m_avg = last_month_rolling_avg THEN 'Stable'
            END AS trend_flag
        FROM last_rolling_average
    )
SELECT
    month,
    customer_segment,
    total_orders,
    total_late_deliveries,
    late_delivery_rate_pct,
    rolling_3m_avg,
    last_month_rolling_avg,
    trend_flag
FROM flagging
ORDER BY month, customer_segment;