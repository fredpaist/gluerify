output "glue_job_name" {
  description = "Name of the Glue job created"
  value       = aws_glue_job.etl_job.name
}

output "aws_iam_role_name" {
  value = aws_iam_role.glue_role.name
}