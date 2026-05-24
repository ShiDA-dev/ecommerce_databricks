-- to compare the gross avg gross total amount difference between discount availed and not availed for each of the categories
CREATE OR REFRESH MATERIALIZED VIEW 
ecommerce_study.`03_gold`.gold_categories_discount_comparison
AS 
-- average gross amount for each category
WITH avg_cat_gross AS (
    SELECT
        product_category,
        COUNT(CASE WHEN discount_availed IS TRUE THEN cid END) AS cust_with_disc,
        COUNT(CASE WHEN discount_availed IS FALSE THEN cid END) AS cust_without_disc,
        AVG(CASE WHEN discount_availed IS TRUE THEN gross_amount END) AS gross_with_disc,
        AVG(CASE WHEN discount_availed IS FALSE THEN gross_amount END) AS gross_without_disc
    FROM
        ecommerce_study.`02_silver`.silver_ecommerce_consumer
    GROUP BY 
        product_category
)
SELECT
    product_category,
    ROUND(cust_with_disc, 2) AS cust_with_disc,
    ROUND(cust_without_disc, 2) AS cust_without_disc,
    ROUND((cust_with_disc - cust_without_disc) / cust_without_disc, 2) * 100 AS cust_incent_pct,
    ROUND(gross_with_disc, 2) AS gross_with_disc,
    ROUND(gross_without_disc, 2) AS gross_without_disc,
    ROUND((gross_with_disc - gross_without_disc) / gross_without_disc, 2) * 100 AS amt_incent_pct
FROM 
    avg_cat_gross
