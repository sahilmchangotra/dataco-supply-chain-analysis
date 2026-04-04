--================================================================================================================
-- INTRODUCING : Sales & Marketing Integrated Questions
-- ✅ Q3 -  Joint Stakeholder Request:
--"We've been going back and forth on which customer segments drive revenue in which departments. Instead of
-- separate reports, we want one matrix — customer segment as rows, department as columns, revenue as values. This
-- will tell us instantly whether Corporate buys more Golf equipment than Consumer, whether Home Office drives Apparel,
-- and so on.Give us a pivot-style revenue matrix — one row per customer segment, one column per department, revenue
-- at each intersection."
--================================================================================================================

-- First check the distinct department names
SELECT DISTINCT department_name FROM supply_chain.orders
WHERE order_status IN ('CLOSED','COMPLETE')
AND delivery_status != 'Shipping canceled'
ORDER BY department_name;

--- the main query

SELECT
    customer_segment,
    ROUND(SUM(CASE WHEN department_name = 'Apparel' THEN sales ELSE 0 END), 2) AS apparel,
    ROUND(SUM(CASE WHEN department_name = 'Book Shop' THEN sales ELSE 0 END), 2) AS book_shop,
    ROUND(SUM(CASE WHEN department_name = 'Discs Shop' THEN sales ELSE 0 END), 2) AS discs_shop,
    ROUND(SUM(CASE WHEN department_name = 'Fan Shop' THEN sales ELSE 0 END), 2) AS fan_shop,
    ROUND(SUM(CASE WHEN department_name = 'Fitness' THEN sales ELSE 0 END), 2) AS fitness,
    ROUND(SUM(CASE WHEN department_name = 'Footwear' THEN sales ELSE 0 END), 2) AS footwear,
    ROUND(SUM(CASE WHEN TRIM(department_name) = 'Golf' THEN sales ELSE 0 END), 2) AS golf,
    ROUND(SUM(CASE WHEN TRIM(department_name) = 'Health and Beauty' THEN sales ELSE 0 END), 2) AS health_beauty,
    ROUND(SUM(CASE WHEN department_name = 'Outdoors' THEN sales ELSE 0 END), 2) AS outdoors,
    ROUND(SUM(CASE WHEN department_name = 'Pet Shop' THEN sales ELSE 0 END), 2) AS pet_shop,
    ROUND(SUM(CASE WHEN department_name = 'Technology' THEN sales ELSE 0 END), 2) AS technology
FROM supply_chain.orders
WHERE order_status IN ('CLOSED', 'COMPLETE')
    AND delivery_status != 'Shipping canceled'
GROUP BY customer_segment
ORDER BY customer_segment;