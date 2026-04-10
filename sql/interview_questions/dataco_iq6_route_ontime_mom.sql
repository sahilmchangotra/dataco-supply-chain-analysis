--================================================================================================================
-- Introducing - Interview Prep Series
-- 📧 IQ6 — Delhivery Data Analyst Interview:
--
-- "We track delivery performance per route — defined as order city to customer city. For each route, calculate the
-- monthly on-time delivery percentage and flag routes that are worsening month over month.
-- A delivery is on-time when delivery_status = 'Advance shipping' or delivery_status = 'Shipping on time'.
-- Show me:
--
-- Route (order_city → customer_city)
-- Month
-- Total shipments
-- On-time shipments
-- On-time rate %
-- Previous month on-time rate (LAG)
-- MoM change %
-- Trend flag: Worsening / Improving / Stable
--
-- Only include routes with at least 50 total shipments across all months.
-- Order by route, month."
--================================================================================================================

WITH delivery_base AS(
    SELECT
        order_city || '->' || customer_city AS route,
        DATE_TRUNC('month', order_date) AS month,
        COUNT( order_id) AS shipment_count,
        COUNT(order_id) FILTER ( WHERE orders.delivery_status IN ('Advance shipping','Shipping on time')) AS on_time_shipments,
        ROUND(COUNT(order_id) FILTER ( WHERE orders.delivery_status IN ('Advance shipping', 'Shipping on time')) * 100.0 /
              NULLIF(COUNT(order_id), 0), 2) AS on_time_rate_pct
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED', 'COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY order_city, customer_city, DATE_TRUNC('month', order_date)
),
    route_total AS (SELECT route,
                           SUM(shipment_count) AS total_shipments
                    FROM delivery_base
                    GROUP BY route
                    HAVING SUM(shipment_count) >= 50
    ),
    flagged AS(
        SELECT
            db.route,
            db.month,
            db.shipment_count,
            db.on_time_shipments,
            db.on_time_rate_pct,
            LAG(db.on_time_rate_pct, 1) OVER (PARTITION BY db.route ORDER BY db.month) AS prev_month_on_time_rate
        FROM delivery_base db
        JOIN route_total rt
            ON db.route = rt.route
    )

SELECT
    route,
    month,
    shipment_count,
    on_time_shipments,
    on_time_rate_pct,
    prev_month_on_time_rate,
    ROUND((on_time_rate_pct - prev_month_on_time_rate) * 100.0 /
            NULLIF(prev_month_on_time_rate,0), 2) AS mom_pct,
    CASE
        WHEN on_time_rate_pct > prev_month_on_time_rate THEN 'Improving'
        WHEN on_time_rate_pct < prev_month_on_time_rate THEN 'Worsening'
        ELSE 'Stable' END AS trend_flag
FROM flagged
ORDER BY route, month;