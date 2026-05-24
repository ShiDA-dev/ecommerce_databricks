from pyspark import pipelines as dp

@dp.materialized_view(
    name="raw_ecommerce_consumer_table",
    comment="Data landed from Neon Postgres database"
)
def neon_postgres_data():
    df = (
        spark.read.format("jdbc")
        .option("url", "jdbc:postgresql://ep-snowy-mountain-aqq0qmt9-pooler.c-8.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require")
        .option("user", "neondb_owner")
        .option("password", dbutils.secrets.get(scope="neon", key="db_password"))
        .option("dbtable", "ecommerce_consumer_table")
        .option("driver", "org.postgresql.Driver")
        .load()
    )
    
    # Rename columns with spaces to use underscores
    for col_name in df.columns:
        if ' ' in col_name:
            df = df.withColumnRenamed(col_name, col_name.replace(' ', '_'))
    
    return df