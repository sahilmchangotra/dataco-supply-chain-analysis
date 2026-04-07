--================================================================================================================
-- INTRODUCING : Product Life Management
-- ✅ Q3 - BOL performance marketing:
-- Now that we have lifecycle stages from PLM Q1, I want a performance scorecard by stage. I need to
-- understand — do Decline products have worse profit ratios? Do Introduction products have lower discount rates?
-- This will tell me where to focus campaign spend.
-- For each lifecycle stage show me:
--
-- Lifecycle stage
-- Total products
-- Total orders
-- Total revenue
-- Avg revenue per product
-- Avg profit ratio
-- Avg discount rate
-- Late delivery rate %
-- Revenue share % of total
--
-- Order by total revenue descending."
--================================================================================================================

WITH ref_date AS(
    SELECT
        MAX(order_date) AS max_date
    FROM supply_chain.orders
),
    current_period AS(
        SELECT
            product_name,
            department_name,
            COUNT(DISTINCT order_id) AS total_orders,
            SUM(sales) AS current_revenue
        FROM supply_chain.orders, ref_date
        WHERE order_status IN ('CLOSED','COMPLETE')
            AND delivery_status != 'Shipping canceled'
            AND order_date >= max_date - INTERVAL '12 months'
        GROUP BY product_name, department_name
    ),
    prior_period AS(
        SELECT
            product_name,
            department_name,
            SUM(sales) AS prior_revenue
        FROM supply_chain.orders, ref_date
        WHERE order_status IN ('CLOSED', 'COMPLETE')
            AND delivery_status != 'Shipping canceled'
            AND order_date >= max_date - INTERVAL '24 months'
            AND order_date < max_date - INTERVAL '12 months'
        GROUP BY product_name, department_name
    ),
    yoy AS (
        SELECT
            c.product_name,
            c.department_name,
            c.total_orders,
            c.current_revenue,
            p.prior_revenue,
            ROUND((c.current_revenue - p.prior_revenue) * 100.0 /
                    NULLIF(p.prior_revenue, 0), 2) AS yoy_growth_pct
        FROM current_period c
        LEFT JOIN prior_period p
            ON c.product_name = p.product_name
            AND c.department_name = p.department_name
    ),
    quantilied AS (
        SELECT
            *,
            NTILE(4) OVER (ORDER BY total_orders) AS order_tier,
            NTILE(4) OVER (order by current_revenue) AS revenue_tier
        FROM yoy
    ),
    lifecycle AS (
        SELECT
            product_name,
            department_name,
            total_orders,
            current_revenue,
            prior_revenue,
            yoy_growth_pct,
            order_tier,
            revenue_tier,
            CASE
                WHEN order_tier = 1 AND revenue_tier = 1 THEN 'Introduction'
                WHEN yoy_growth_pct > 10 AND order_tier >= 2 THEN 'Growth'
                WHEN order_tier = 4 AND ABS(yoy_growth_pct) <= 10 THEN 'Maturity'
                WHEN yoy_growth_pct < - 10 AND order_tier <= 2 THEN 'Decline'
                ELSE 'Mixed'
            END AS lifecycle_stage
        FROM quantilied
    ),
    stage_metrics AS(
        SELECT
            l.lifecycle_stage,
            COUNT(DISTINCT l.product_name) AS total_products,
            COUNT(DISTINCT o.order_id) AS total_orders,
            SUM(o.sales) AS total_revenue,
            ROUND(SUM(o.sales) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS avg_revenue_per_order,
            ROUND(AVG(o.order_item_profit_ratio), 2) AS avg_profit_ratio,
            ROUND(AVG(o.order_item_discount_rate), 2) AS avg_discount_rate,
            ROUND(COUNT(o.order_id) FILTER ( WHERE o.delivery_status = 'Late delivery' ) * 100.0 /
                    NULLIF(COUNT(o.order_id), 0), 2) AS late_delivery_rate_pct
        FROM lifecycle l
        JOIN supply_chain.orders o
            ON l.product_name = o.product_name
            AND l.department_name = o.department_name
        WHERE o.order_status IN ('CLOSED', 'COMPLETE')
            AND o.delivery_status != 'Shipping canceled'
        GROUP BY l.lifecycle_stage
    )
        SELECT
            lifecycle_stage,
            total_products,
            total_orders,
            total_revenue,
            avg_revenue_per_order,
            avg_profit_ratio,
            avg_discount_rate,
            late_delivery_rate_pct,
            ROUND(total_revenue * 100.0 /
                  NULLIF(SUM(total_revenue) OVER (), 0), 2) AS revenue_share_pct,
            RANK() OVER (ORDER BY total_revenue DESC) AS rank
        FROM stage_metrics
        ORDER BY rank;