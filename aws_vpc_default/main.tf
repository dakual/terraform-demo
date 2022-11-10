terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.38.0"
    }
  }

  required_version = ">= 1.2.5"
}

provider "aws" {
  region = local.region
}

locals {
  name            = "default"
  environment     = "dev"
  region          = "eu-central-1"
}

module "vpc" {
  source              = "./vpc"
  name                = local.name
  environment         = local.environment
  cidr                = "172.31.0.0/16"
  private_subnets     = ["172.31.0.0/20", "172.31.16.0/20", "172.31.32.0/20"]
  public_subnets      = ["172.31.48.0/20", "172.31.64.0/20", "172.31.80.0/20"]
  availability_zones  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

resource "aws_default_security_group" "default" {
  vpc_id      = module.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
