CREATE OR REFRESH MATERIALIZED VIEW 
ecommerce_study.`03_gold`.gold_age_group_preferences
AS 
WITH category_counts AS (
    SELECT 
        age_group,
        product_category,
        COUNT(*) AS cat_count
    FROM
        ecommerce_study.`02_silver`.silver_ecommerce_consumer
    GROUP BY 
        age_group, product_category
),
category_rank AS (
    SELECT 
        age_group,
        product_category,
        cat_count,
        DENSE_RANK() OVER (PARTITION BY age_group ORDER BY cat_count DESC) AS cat_rank
    FROM category_counts
),
age_group_stats AS (
    SELECT
        age_group,
        COUNT(cid) AS cust_count,
        ROUND(AVG(discount_amount), 2) AS avg_disc,
        ROUND(AVG(gross_amount), 2) AS avg_gross_amt
    FROM
        ecommerce_study.`02_silver`.silver_ecommerce_consumer
    GROUP BY
        age_group
)
SELECT
    age_group_stats.age_group,
    cust_count,
    avg_disc,
    avg_gross_amt,
    product_category,
    cat_count
FROM
    age_group_stats 
    LEFT JOIN category_rank ON category_rank.age_group = age_group_stats.age_group
WHERE
    category_rank.cat_rank = 1
