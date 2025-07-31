terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

# AWS Glue ETL CSV-to-CSV Pipeline with Terraform
provider "aws" {
  region     = var.aws_region
  profile    = "LearningSharedAccess"
}