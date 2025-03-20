# Terraform Block
terraform {
  required_version = ">= 1.0" # which means any version equal & above 0.14 like 0.15, 0.16 etc and < 1.xx
  required_providers {
    aws = ">= 5.1.0"
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket  = "terraform-states"
    encrypt = true
    key     = "terraform.tfstate"
    region  = "us-east-1"
  }
}

# Provider Block
provider "aws" {
  region = var.region
}
