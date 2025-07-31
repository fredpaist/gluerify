import sys

import boto3
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import functions as F
from pyspark.sql.functions import current_timestamp, add_months, to_timestamp, concat, col, lit, trim, regexp_replace


def doStuff():
    s3 = boto3.client("s3")
    bucket = "fred-learning-glueify"
    output_prefix = "temp/"  # no s3://, just path inside bucket
    final_key = "output/output.csv"

    # List part files
    response = s3.list_objects_v2(Bucket=bucket, Prefix=output_prefix)

    # Check if there are any contents
    if 'Contents' not in response or not response['Contents']:
        print(f"No files found in s3://{bucket}/{output_prefix}")
        return

    # Try to find a Spark part file (typically named like "part-r-00000" or "part-00000")
    part_files = [obj['Key'] for obj in response['Contents'] if 'part-' in obj['Key']]

    if not part_files:
        print(f"No part files found in s3://{bucket}/{output_prefix}")
        print(f"Available files: {[obj['Key'] for obj in response['Contents']]}")
        return

    # Use the first part file found
    part_file = part_files[0]

    # Copy to fixed name
    s3.copy_object(Bucket=bucket, CopySource={"Bucket": bucket, "Key": part_file}, Key=final_key)

    # Optionally delete temporary part file and folder
    s3.delete_object(Bucket=bucket, Key=part_file)


# Get job parameters
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'input_path',
    'output_path',
    'temp_path'
])

# Initialize Spark and Glue contexts
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Log job parameters
print(f"Input path: {args['input_path']}")
print(f"Output path: {args['output_path']}")

# Read input CSV files
# Note: You can customize the CSV options based on your input format
print("Reading input CSV files...")
input_dyf = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={
        "paths": [args['input_path']],
        "recurse": True,
    },
    format="csv",
    format_options={
        "withHeader": True,
        "separator": ";",
        "optimizePerformance": True,
        "multiline": True,
        "skipFirst": True
    }
)

five_years_ago = add_months(current_timestamp(), -60)

# Print the schema of the input data
print("Input schema:")
input_dyf.printSchema()

# Convert to DataFrame for easier manipulation
input_df = input_dyf.toDF()

print("Original column names:", input_df.columns)

input_df = input_df.withColumnRenamed("col0", "ID") \
    .withColumnRenamed("col1", "NAME") \
    .withColumnRenamed("col2", "TYPE") \
    .withColumnRenamed("col3", "MOTOR") \
    .withColumnRenamed("col4", "PRODUCTION_DATE") \
    .withColumnRenamed("col5", "STATUS") \
    .withColumnRenamed("col6", "LAST_REPAIR_DATE_TIME")


# Clean column names (remove trailing newline and spaces)
cleaned_columns = [col.strip() for col in input_df.columns]
input_df = input_df.toDF(*cleaned_columns)
print(f"Input record count: {input_df.count()}")

# TRANSFORMATION SECTION
# This is where you would add your custom transformations
# Below is a simple example that you can modify as needed

transformed_df = input_df.withColumn(
    "LAST_REPAIR_DATE_TIME",
    regexp_replace(trim(F.col("LAST_REPAIR_DATE_TIME")), r"\r?\n$", "")
)

# Filter rows
transformed_df = input_df.withColumn(
    "LAST_REPAIR_DATE_TIME",
    to_timestamp(F.col("LAST_REPAIR_DATE_TIME"), "yyyy-MM-dd'T'HH:mm:ss")
).filter(
    F.col("LAST_REPAIR_DATE_TIME") > five_years_ago
)

# Example: Transform column
transformed_df = input_df.withColumn(
    "PRODUCTION_DATE",
    to_timestamp(concat(F.col("PRODUCTION_DATE"), lit("T12:00:00")), "yyyy-MM-dd'T'HH:mm:ss")
)

# Convert back to DynamicFrame
transformed_dyf = DynamicFrame.fromDF(transformed_df, glueContext, "transformed_data")

# Write the transformed data to S3 in CSV format
print("Writing output CSV files...")
output_options = {
    "path": args['temp_path'],
    "partitionKeys": []
}

glueContext.write_dynamic_frame.from_options(
    frame=transformed_dyf,
    connection_type="s3",
    connection_options=output_options,
    format="csv",
    format_options={
        "separator": ",",
        "quoteChar": '"',
        "writeHeader": True
    }
)

print(f"Transformation complete. Output written to: {args['output_path']}")

doStuff()

# Commit the job
job.commit()
