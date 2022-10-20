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
  region = var.region
}



module "vpc" {
  source              = "./vpc"
  name                = var.name
  cidr                = var.cidr
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  availability_zones  = var.availability_zones
  environment         = var.environment
}

module "security_groups" {
  source              = "./security-groups"
  name                = var.name
  vpc_id              = module.vpc.id
  environment         = var.environment
  container_port      = var.container_port
}

module "alb" {
  source              = "./alb"
  name                = var.name
  vpc_id              = module.vpc.id
  subnets             = module.vpc.public_subnets
  environment         = var.environment
  alb_security_groups = [ module.security_groups.alb ]
  alb_tls_cert_arn    = var.tsl_certificate_arn
  health_check_path   = var.health_check_path
}

# module "ecr" {
#   source      = "./ecr"
#   name        = var.name
#   environment = var.environment
# }

module "ecs" {
  source                      = "./ecs"
  name                        = var.name
  environment                 = var.environment
  region                      = var.aws-region
  subnets                     = module.vpc.private_subnets
  aws_alb_target_group_arn    = module.alb.aws_alb_target_group_arn
  ecs_service_security_groups = [ module.security_groups.ecs_tasks ]
  container_image             = var.container_image
  container_port              = var.container_port
  container_cpu               = var.container_cpu
  container_memory            = var.container_memory
  service_desired_count       = var.service_desired_count
  container_environment       = [{ name = "LOG_LEVEL", value = "DEBUG" }, { name = "PORT", value = var.container_port }]
}