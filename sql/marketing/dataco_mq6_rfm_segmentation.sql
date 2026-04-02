--===============================================================================================================
-- INTRODUCING : Marketing Questions
-- ✅ Q6 -  bol performance marketing:
-- "I need to segment our customers using RFM — Recency, Frequency, Monetary. This is going into our retention
-- campaign targeting so I need it clean and actionable.
-- Use NTILE(4) to score each dimension — then combine the scores into segments. For each customer show me:
--
-- Customer ID
-- Recency score (1–4, 4 = most recent)
-- Frequency score (1–4, 4 = most frequent)
-- Monetary score (1–4, 4 = highest spend)
-- RFM combined score (R + F + M)
-- Segment label: Champion, Loyal, At Risk, Lost
--
-- Then summarise by segment — total customers, avg RFM score, avg monetary value.
-- Same filters as always. Use MAX(order_date) as reference date — not CURRENT_DATE."
--===============================================================================================================

WITH customer_base AS(
    SELECT
        customer_id,
        order_id,
        sales,
        order_date
    FROM supply_chain.orders
    WHERE order_status IN ('CLOSED','COMPLETE')
        AND delivery_status != 'Shipping canceled'
),
    rfm_base AS(
        SELECT
            customer_id,
            COUNT(DISTINCT order_id)::BIGINT AS frequency,
            SUM(sales)::NUMERIC AS monetary,
            DATE_PART('day',
                (SELECT MAX(order_date) FROM supply_chain.orders)
                - MAX(order_date))::NUMERIC AS recency
        FROM customer_base
        GROUP BY customer_id
    ),
    quantile_range AS(
        SELECT
            *,
            NTILE(4) OVER (ORDER BY recency ASC) as r_score,
            NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
            NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
        FROM rfm_base
    ),
    rfm_score AS(
        SELECT
            *,
            CASE
                WHEN r_score + f_score + m_score >= 10 THEN 'Champion'
                WHEN r_score + f_score + m_score >= 7  THEN 'Loyal'
                WHEN r_score + f_score + m_score >= 5  THEN 'At Risk High Value'
                ELSE 'Lost'
            END AS rfm_segment
        FROM quantile_range
    )
SELECT
    rfm_segment,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(r_score + f_score + m_score), 2) AS avg_rfm_score,
    ROUND(AVG(monetary), 2) AS avg_monetary_value
FROM rfm_score
GROUP BY rfm_segment
ORDER BY avg_rfm_score DESC;