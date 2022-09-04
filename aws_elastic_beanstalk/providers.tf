terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.27.0"
    }
  }

  # backend "s3" {
  #   bucket = "terraform-state-bucket-eu-west-1"
  #   key = "myapp/terraform.tfstate"
  #   shared_credentials_file = "$HOME/.aws/credentials"
  #   region = "eu-west-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt = true
  # }
  
  required_version = ">= 1.2.5"
}

provider "aws" {
  region = var.aws_region
}