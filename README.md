# 📘 AWS Glue ETL CSV-to-CSV Pipeline with Terraform

## 🎯 Goal

Automate the setup of an AWS Glue ETL pipeline that:

- Reads **CSV files** from a source S3 bucket
- Optionally transforms the data using PySpark
- Writes the transformed data back to **S3** in **CSV format**

All infrastructure is provisioned using **Terraform**.

---

## 🧱 Components

| Component | Purpose |
|----------|---------|
| **S3 Bucket** | Stores source CSV files, transformed output, job scripts, and temp data |
| **IAM Role** | Grants AWS Glue permission to access S3 and CloudWatch |
| **Glue Job** | Executes the ETL logic using PySpark |
---

## 🗂️ Directory Structure

```
project/
├── main.tf                  # Terraform infrastructure
├── variables.tf             # Customizable variables
├── glue_job_script.py       # PySpark transformation logic
└── README.md                # This document
```

---

## 🛠️ Terraform Setup Overview

### 1. S3 Bucket
- Create a single S3 bucket to store:
  - **Input files** (e.g., `input/`)
  - **Output files** (e.g., `output/`)
  - **Job script** (e.g., `scripts/glue_job_script.py`)
  - **Temporary Glue data** (e.g., `temp/`)

### 2. IAM Role
- Trust relationship with `glue.amazonaws.com`
- Permissions to:
  - Read/write to the S3 bucket
  - Log to CloudWatch
  - Manage Glue resources (if needed)

### 3. Glue Job
- Type: **Spark (Python 3)**
- Version: **Glue 5.0**
- Reads from `input/`, writes to `output/`
- Uses script stored in S3 (`scripts/glue_job_script.py`)
- Optional arguments: `--TempDir`, `--job-language`, logging flags

---

## 💻 Glue Job Script Overview (`glue_job_script.py`)

- Uses AWS Glue DynamicFrame API to:
  - Load data from S3 in CSV format
  - Apply optional transformations
  - Write data back to S3 in CSV format

Minimal transformation logic can be added with PySpark or AWS Glue `ApplyMapping`.

---

## ✅ Execution Flow

1. Upload source CSV file to:
   ```
   s3://<bucket-name>/input/
   ```

2. Trigger the Glue job:
   - Via the AWS Console
   - Or via `aws glue start-job-run` CLI

3. Output is saved to:
   ```
   s3://<bucket-name>/output/
   ```

---

## 🔐 Security Notes

- Enable **S3 encryption**
- Restrict IAM permissions (least privilege)
- Block public access on S3 bucket


---

## 📎 Dependencies

- Terraform v1.3+
- AWS CLI (for manual upload & job run)
- AWS Glue (enabled in region)

---

## 🚀 Outcome

After deployment, you will have a fully working ETL pipeline that:

- Is **infrastructure-as-code**
- Scales with Glue's serverless compute
- Stores all CSV inputs and outputs in S3cat 