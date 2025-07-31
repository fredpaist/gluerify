# IAM policy for AWS Glue to use KMS for encryption/decryption
resource "aws_iam_policy" "fred_glue_kms_policy" {
  name        = "GlueKMSPolicy"
  description = "Policy for AWS Glue to use KMS keys for S3 encryption/decryption"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = [
          data.aws_kms_key.fred_stuff.arn
        ]
      }
    ]
  })
}