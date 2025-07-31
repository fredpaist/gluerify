
# main.tf
module "s3_bucket" {
  source = "./modules/s3"
  bucket_resource_name_suffix = var.bucket_resource_name_suffix
  resource_name_prefix = var.resource_name_prefix
}


module "glue_job" {
  source = "./modules/glue"

  glue_job_name     = var.glue_job_name
  glue_role_name    = var.glue_role_name
  bucket_id         = module.s3_bucket.bucket_id
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  script_path       = "${path.module}/../scripts/glue_job_script.py"
}


# FOR testing upload test csv also to s3
resource "aws_s3_object" "fred_random_test_data" {
  bucket = module.s3_bucket.bucket_id
  key    = "input/star_wars_vehicles.csv"
  source = "${path.module}/../test_data/star_wars_vehicles.csv"
  etag   = filemd5("${path.module}/../test_data/star_wars_vehicles.csv")
}
