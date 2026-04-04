--================================================================================================================
-- INTRODUCING : Sales & Marketing Integrated Questions
-- ✅ Q4 -  Revenue Analytics:
--I need to identify which product categories are experiencing profit ratio decline month over month. Not just
-- one bad month — I want to see a sustained trend. For each category show me the monthly profit ratio, compare it to
-- the previous month, flag whether it's improving or declining, and count how many consecutive months it has been
-- declining.
-- For each category and month show me:
--
-- Category name
-- Month
-- Avg profit ratio
-- Previous month profit ratio (LAG)
-- Month over month change
-- Trend flag: Improving / Declining / Stable
-- Consecutive declining months count
--================================================================================================================

-- NOTE: Consecutive declining months counter uses a CUMULATIVE
-- SUM pattern — not a true reset counter.
-- Example: Declined 3 months → Improved → Declined 2 months. This query shows: 5 (cumulative), not 2 (since last reset)
-- A true reset counter requires a gaps-and-islands pattern (ROW_NUMBER difference technique) which is more complex.
-- For portfolio purposes, cumulative count is acceptable and still surfaces categories with persistent decline signals.
--================================================================================================================


WITH category_base AS(
    SELECT
    category_name,
    EXTRACT(MONTH FROM order_date) AS month,
    ROUND(AVG(order_item_profit_ratio), 2) AS avg_profit_ratio
FROM orders
WHERE order_status IN ('CLOSED','COMPLETE')
    AND delivery_status!='Shipping canceled'
GROUP BY category_name, EXTRACT(MONTH FROM order_date)
),
    previous_month_agg AS(
        SELECT
            *,
            LAG(avg_profit_ratio) OVER (
                PARTITION BY category_name
                ORDER BY month) AS prev_month_ratio
        FROM category_base
    ),
    month_on_month AS(
        SELECT
            *,
            ROUND((avg_profit_ratio - prev_month_ratio) * 100.0 /
                    NULLIF(prev_month_ratio,0), 2) AS mom_change_pct
        FROM previous_month_agg
    ),
    flagging AS(
        SELECT
            *,
            CASE
                WHEN avg_profit_ratio > prev_month_ratio THEN 'Improving'
                WHEN avg_profit_ratio < prev_month_ratio THEN 'Declining'
                WHEN prev_month_ratio IS NULL THEN 'New'
                ELSE 'Stable'
            END AS trend_flag
        FROM month_on_month
    )
SELECT
    category_name,
    month,
    avg_profit_ratio,
    prev_month_ratio,
    mom_change_pct,
    trend_flag,
    SUM(CASE WHEN trend_flag = 'Declining' THEN 1 ELSE 0 END) OVER (
        PARTITION BY category_name ORDER BY month ROWS BETWEEN UNBOUNDED
        PRECEDING AND CURRENT ROW
        ) AS consec_declining_months
FROM flagging
ORDER BY category_name;