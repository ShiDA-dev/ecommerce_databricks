from pyspark import pipelines as dp

from pyspark.sql.functions import( 
    col, when, to_timestamp, lower, round
)

@dp.materialized_view(
    name="ecommerce_study.`02_silver`.silver_ecommerce_consumer",
    comment="Silver layer: cleaned ecommerce consumer data with proper data types",
    table_properties={
        "quality": "silver"
    }
)

# filter invalid data
@dp.expect_all({
    "valid CID": "CID IS NOT NULL AND CID > 100000",
    "vaiid TID": "TID IS NOT NULL AND TID > 1000000000"
})

# standardize
def silver_ecommerce_consumer():
    df = spark.read.table("ecommerce_study.01_bronze.raw_ecommerce_consumer_table")
    return (
        df
        # lowercase all columns
        .withColumnsRenamed({c: c.lower() for c in df.columns})
        # time format
        .withColumn("purchase_date", to_timestamp(col("purchase_date"), "dd/MM/yyyy HH:mm:ss"))
        # round numeric value
        .withColumn("discount_amount", round(col("discount_amount"), 2))
        .withColumn("gross_amount", round(col("gross_amount"), 2))
        .withColumn("net_amount", round(col("net_amount"), 2))
        # change binary string to boolean
        .withColumn("discount_availed", 
            when(lower(col("discount_availed")) == "yes", True)
            .when(lower(col("discount_availed")) == "no", False)
            .otherwise(None))
    )
