terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }
  required_version = ">= 1.6.0"

  backend "s3" {
    profile        = "Terraform"
    bucket         = "three-tier-tf-bucket"
    key            = "three-tier-tf-state"
    region         = "eu-west-2"
    dynamodb_table = "three-tier-tf-lock"
    encrypt        = true
  }
}
