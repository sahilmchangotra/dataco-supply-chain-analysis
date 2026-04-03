--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Bonus Question 2 -  bol performance marketing:
-- "I want to identify our hero products — the ones driving disproportionate revenue. For each product show me its
-- revenue, what percentage of its department's total revenue it represents, its rank within its department, and
-- flag any product that single-handedly accounts for more than 20% of its department's revenue as a 'Hero Product'.
-- Show top 5 products per department only.
-- Same filters as always."
--===============================================================================================================

WITH product_base AS(
    SELECT
        product_name,
        department_name,
        SUM(sales) AS total_revenue
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
    GROUP BY product_name, department_name
),
    product_agg AS(
        SELECT
            product_name,
            department_name,
            total_revenue,
            SUM(total_revenue) OVER (PARTITION BY department_name) AS department_total,
            ROUND(total_revenue * 100.0 /
                  NULLIF(SUM(total_revenue) OVER (PARTITION BY department_name), 0), 2) AS dept_revenue_share_pct,
            DENSE_RANK() OVER (PARTITION BY department_name ORDER BY total_revenue DESC) AS dept_rank
        FROM product_base
        GROUP BY product_name, department_name, total_revenue
    )
SELECT
    product_name,
    department_name,
    total_revenue,
    department_total,
    dept_revenue_share_pct,
    dept_rank,
    CASE WHEN dept_revenue_share_pct >= 20 THEN 'Hero Product'
        ELSE 'Normal'
    END AS product_flag
FROM product_agg
WHERE dept_rank <= 5
ORDER BY dept_rank;