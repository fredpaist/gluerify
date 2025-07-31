
output "bucket_id" {
  description = "The name of the bucket"
  value       = module.fred_bucket.bucket_id
}

output "glue_kms_policy_arn" {
  value = aws_iam_policy.fred_glue_kms_policy.arn
}
