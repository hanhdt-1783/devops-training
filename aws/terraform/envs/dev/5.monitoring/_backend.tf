terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version= "6.14.1"
    }
  }

  backend "s3" {
    profile        = "devops-training-dev"
    bucket         = "devops-training-dev-iac-state"
    key            = "5.monitoring/terraform.dev.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:ap-northeast-1:471112727684:key/dccae7fb-b958-4827-97de-9a3e288a556b"
    dynamodb_table = "devops-training-dev-terraform-state-lock"
  }
}

provider "aws" {
  region  = var.region
  profile = "${var.project}-${var.env}"
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.env
    }
  }
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "general" {
  backend = "s3"
  config = {
    profile = "devops-training-dev"
    bucket  = "devops-training-dev-iac-state"
    key     = "1.general/terraform.dev.tfstate"
    region  = var.region
  }
}
