--================================================================================================================
-- INTRODUCING : Pivot Practice
-- ✅ Q1 -   bol category marketing:
--"I want to see a monthly revenue heatmap in SQL. For each department show me revenue broken out by month —
-- one row per department, one column per month (1–12). This will let me instantly see which departments peak in
-- which months and spot seasonal patterns.
--One row per department, 12 monthly revenue columns."
--================================================================================================================

SELECT
    department_name,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 1 THEN sales ELSE 0 END) AS jan,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 2 THEN sales ELSE 0 END) AS feb,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 3 THEN sales ELSE 0 END) AS mar,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 4 THEN sales ELSE 0 END) AS apr,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 5 THEN sales ELSE 0 END) AS may,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 6 THEN sales ELSE 0 END) AS jun,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 7 THEN sales ELSE 0 END) AS jul,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 8 THEN sales ELSE 0 END) AS aug,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 9 THEN sales ELSE 0 END) AS sep,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 10 THEN sales ELSE 0 END) AS oct,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 11 THEN sales ELSE 0 END) AS nov,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 12 THEN sales ELSE 0 END) AS dec,
    ROUND(SUM(sales), 2) AS total_revenue
FROM orders
WHERE order_status IN ('CLOSED','COMPLETE')
    AND delivery_status != 'Shipping canceled'
GROUP BY department_name;