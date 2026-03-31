--==========================================================================================
-- INTRODUCING : LOGISTICS Practice SQL
-- DataCo Logistics Operations:
-- I need a monthly delivery performance report. For each month show me: total orders, on-time
-- deliveries, late deliveries, late delivery rate as a percentage, and a 3-month rolling average
-- of the late delivery rate. Flag any month, where the late delivery rate exceeds 20% as an Alert month.
-- I want to see if our delivery network is getting better or worse over time."
--==========================================================================================

-- One row in my base CTE = one order


SELECT
    year_month,
    total_orders,
    on_time_deliveries,
    late_deliveries,
    late_delivery_rate_pct,
    ROUND(AVG(late_delivery_rate_pct) OVER (
        ORDER BY year_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::NUMERIC, 2) AS rolling_3m_avg,
    CASE
        WHEN late_delivery_rate_pct > 60 THEN 'Critical'
        WHEN late_delivery_rate_pct > 55 THEN 'Alert'
        ELSE 'Normal'
    END AS Flag
FROM(
    SELECT
        TO_CHAR(order_date,'YYYY-MM') AS year_month,
        COUNT(order_id) AS total_orders,
        COUNT(*) FILTER ( WHERE delivery_status IN ('Shipping on time','Advance shipping') ) AS on_time_deliveries,
        COUNT(*) FILTER ( WHERE delivery_status = 'Late delivery' ) AS late_deliveries,
        ROUND((COUNT(*) FILTER ( WHERE delivery_status = 'Late delivery' )) * 100.0 /
                NULLIF(COUNT(*) FILTER ( WHERE delivery_status != 'Shipping canceled' ),0)::NUMERIC, 2) AS late_delivery_rate_pct
    FROM supply_chain.orders
    WHERE order_status IN ('COMPLETE', 'CLOSED')
        AND delivery_status != 'Shipping canceled'
        AND order_date IS NOT NULL
        AND TO_CHAR(order_date,'YYYY-MM') < '2018-01'
    GROUP BY TO_CHAR(order_date,'YYYY-MM')
    ) AS monthly_stats
ORDER BY year_month;