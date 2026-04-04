--================================================================================================================
-- INTRODUCING : Pivot Practice
-- ✅ Q2 -   bol performance marketing:
--"I want to see late delivery rate as a pivot — shipping mode as rows, quarter as columns. This gives me
-- one clean view of whether each shipping mode's late delivery performance is getting better or worse across
-- Q1, Q2, Q3, Q4.
--One row per shipping mode, 4 quarterly late rate % columns, plus an overall late rate column. Add the First
-- Class data quality flag as always."
--================================================================================================================

SELECT
    shipping_mode,
    ROUND(COUNT(CASE WHEN EXTRACT(QUARTER FROM order_date) = 1 AND
                  delivery_status = 'Late delivery' THEN 1 END) * 100.0 /
            NULLIF(COUNT(CASE WHEN EXTRACT(QUARTER FROM order_date) = 1
                   THEN 1 END), 0), 2) AS q1_late_rate_pct,
    ROUND(COUNT(CASE WHEN EXTRACT(QUARTER FROM order_date) = 2 AND
                  delivery_status = 'Late delivery' THEN 1 END) * 100.0 /
            NULLIF(COUNT(CASE WHEN EXTRACT(QUARTER FROM order_date) = 2
                   THEN 1 END), 0), 2) AS q2_late_rate_pct,
    ROUND(COUNT(CASE WHEN EXTRACT(QUARTER FROM order_date) = 3 AND
                  delivery_status = 'Late delivery' THEN 1 END) * 100.0 /
            NULLIF(COUNT(CASE WHEN EXTRACT(QUARTER FROM order_date) = 3
                   THEN 1 END), 0), 2) AS q3_late_rate_pct,
    ROUND(COUNT(CASE WHEN EXTRACT(QUARTER FROM order_date) = 4 AND
                  delivery_status = 'Late delivery' THEN 1 END) * 100.0 /
            NULLIF(COUNT(CASE WHEN EXTRACT(QUARTER FROM order_date) = 4
                   THEN 1 END), 0), 2) AS q4_late_rate_pct,
    ROUND(COUNT(CASE WHEN delivery_status = 'Late delivery' THEN 1 END) * 100.0 /
          NULLIF(COUNT(order_id), 0), 2) AS overall_late_rate_pct,
    CASE
        WHEN shipping_mode = 'First Class'
        THEN '⚠️ Data Quality — 100% Late'
        ELSE '✅'
    END AS data_quality_flag
FROM orders
WHERE order_status IN ('CLOSED', 'COMPLETE')
    AND delivery_status != 'Shipping canceled'
GROUP BY shipping_mode;