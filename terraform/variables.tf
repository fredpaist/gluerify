# Variables for AWS Glue ETL CSV-to-CSV Pipeline

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-north-1"
}

variable "resource_name_prefix" {
  description = "Prefix used for resource naming"
  type        = string
  default     = "fred-learning"
}

variable "bucket_resource_name_suffix" {
  description = "Suffix for the bucket resource name. This will be used as a last part of bucket name."
  type        = string
  nullable    = true
  default     = "glueify"
}

variable "glue_role_name" {
  description = "Name of the IAM role for AWS Glue"
  type        = string
  default     = "GlueETLRole"
}

variable "glue_job_name" {
  description = "Name of the AWS Glue job"
  type        = string
  default     = "fred-csv-to-csv-etl-job"
}

variable "worker_type" {
  description = "Type of worker to use for the Glue job (G.1X, G.2X, etc.)"
  type        = string
  default     = "G.1X"
}

variable "number_of_workers" {
  description = "Number of workers to use for the Glue job"
  type        = number
  default     = 2
}