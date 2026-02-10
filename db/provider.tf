terraform {
  required_version = "1.14.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }
}

provider "aws" {
  region  = local.config.region
  assume_role {
    role_arn = local.config.assume_role_arn
  }
}