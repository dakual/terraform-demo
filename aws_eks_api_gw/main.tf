terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.38.0"
    }
  }
}

provider "aws" {
  region = local.region
}

locals {
  name            = "demo"
  environment     = "dev"
  region          = "eu-central-1"
}

