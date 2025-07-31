# Upload Glue job script to S3
resource "aws_s3_object" "glue_job_script" {
  bucket = var.bucket_id
  key    = "scripts/glue_job_script.py"
  source = var.script_path
  etag   = filemd5(var.script_path)
}

# AWS Glue job
resource "aws_glue_job" "etl_job" {
  name     = var.glue_job_name
  role_arn = aws_iam_role.glue_role.arn

  glue_version = "5.0"

  command {
    name            = "glueetl"
    script_location = "s3://${var.bucket_id}/${aws_s3_object.glue_job_script.key}"
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir"              = "s3://${var.bucket_id}/temp/"
    "--job-language"         = "python"
    "--enable-metrics"       = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--input_path"           = "s3://${var.bucket_id}/input/"
    "--output_path"          = "s3://${var.bucket_id}/output/"
    "--temp_path"          = "s3://${var.bucket_id}/temp/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  timeout = 2880  # 48 hours in minutes

  # Number of workers and worker type can be adjusted based on workload
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
}