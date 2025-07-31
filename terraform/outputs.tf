output "s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = module.s3_bucket.bucket_id
}

output "glue_job_name" {
  description = "Name of the Glue job created"
  value       = module.glue_job.glue_job_name
}

output "input_path" {
  description = "S3 path for input files"
  value       = "s3://${module.s3_bucket.bucket_id}/input/"
}

output "output_path" {
  description = "S3 path for output files"
  value       = "s3://${module.s3_bucket.bucket_id}/output/"
}