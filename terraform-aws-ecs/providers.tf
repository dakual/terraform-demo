terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.27.0"
    }
  }

# this is my remote. i close it because if you run this code you will take error
  # backend "remote" {
  #   hostname = "app.terraform.io"
  #   organization = "dakual"

  #   workspaces {
  #     name = "redacre-aws.ecs"
  #   }
  # }

  required_version = ">= 1.2.5"
}

provider "aws" {
  region = local.region
}