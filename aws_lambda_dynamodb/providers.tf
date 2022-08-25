terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.27.0"
    }
  }
  
  required_version = ">= 1.2.5"
}

provider "aws" {
  region = var.aws_region
}