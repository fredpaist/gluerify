# IAM policy for AWS Glue to access S3
resource "aws_iam_policy" "fred_glue_s3_policy" {
  name        = "GlueS3Policy"
  description = "Policy for AWS Glue to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.resource_name_prefix}-glueify/input/*",
          "arn:aws:s3:::${var.resource_name_prefix}-glueify/output/*",
          "arn:aws:s3:::${var.resource_name_prefix}-glueify/scripts/*",
          "arn:aws:s3:::${var.resource_name_prefix}-glueify/temp/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.resource_name_prefix}-glueify"
        ]
      }

    ]
  })
}

# IAM policy for AWS Glue to log to CloudWatch
resource "aws_iam_policy" "fred_glue_cloudwatch_policy" {
  name        = "GlueCloudWatchPolicy"
  description = "Policy for AWS Glue to log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach S3 policy to Glue role
resource "aws_iam_role_policy_attachment" "fred_glue_s3_attachment" {
  role       = module.glue_job.aws_iam_role_name
  policy_arn = aws_iam_policy.fred_glue_s3_policy.arn
}

# Attach CloudWatch policy to Glue role
resource "aws_iam_role_policy_attachment" "fred_glue_cloudwatch_attachment" {
  role       = module.glue_job.aws_iam_role_name
  policy_arn = aws_iam_policy.fred_glue_cloudwatch_policy.arn
}

# Attach AWS managed Glue service policy to Glue role
resource "aws_iam_role_policy_attachment" "glue_service_attachment" {
  role       = module.glue_job.aws_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}



# Attach KMS policy to Glue role
resource "aws_iam_role_policy_attachment" "fred_glue_kms_attachment" {
  role       = module.glue_job.aws_iam_role_name
  policy_arn = module.s3_bucket.glue_kms_policy_arn
}
