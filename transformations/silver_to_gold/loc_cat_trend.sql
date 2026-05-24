CREATE OR REFRESH MATERIALIZED VIEW 
ecommerce_study.`03_gold`.gold_loc_cat_trend
AS 
SELECT
    location,
    product_category,
    COUNT(tid) AS total_order,
    DENSE_RANK() OVER (PARTITION BY location ORDER BY COUNT(tid) DESC) AS cat_rank,
    ROUND(AVG(gross_amount),2) AS avg_gross_amt
FROM
    ecommerce_study.`02_silver`.silver_ecommerce_consumer
GROUP BY 
    location, product_category
