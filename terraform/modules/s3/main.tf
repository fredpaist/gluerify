
# Create a KMS key for S3 bucket encryption
resource "aws_kms_key" "fred_stuff" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags = {
    Name = "fred_stuff_key"
  }
}

# Create an alias for the KMS key
resource "aws_kms_alias" "fred_stuff" {
  name          = "alias/fred_stuff"
  target_key_id = aws_kms_key.fred_stuff.key_id
}

# Reference the KMS key we created
data "aws_kms_key" "fred_stuff" {
  key_id     = aws_kms_alias.fred_stuff.name
  depends_on = [aws_kms_alias.fred_stuff]
}


module "fred_bucket" {
  source                      = "git::https://gitlab.lhv.eu/dev-infrastructure/terraform/modules/aws-s3-bucket.git?ref=release/0.0.3"
  resource_name_prefix        = var.resource_name_prefix
  bucket_resource_name_suffix = var.bucket_resource_name_suffix
  versioning_enabled          = false
  sse_kms_creation = {
    enabled = false
  }
  sse_kms_byok = {
    enabled     = true
    kms_key_arn = data.aws_kms_key.fred_stuff.arn
  }
}

## Create folders
resource "aws_s3_object" "input_folder" {
  bucket = module.fred_bucket.bucket_id
  key    = "input/"
  content_type = "application/x-directory"
  # Empty folder, just a placeholder object
  source = "/dev/null"
}

resource "aws_s3_object" "output_folder" {
  bucket = module.fred_bucket.bucket_id
  key    = "output/"
  content_type = "application/x-directory"
  source = "/dev/null"
}