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

module "iam" {
  source              = "./iam"
  name                = var.name
  environment         = var.environment
}

module "rds" {
  source              = "./rds"
  name                = var.name
  environment         = var.environment
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  rds_security_groups = [ module.vpc.rds ]
  rds_subnets         = module.vpc.private_subnets
}

module "vpc" {
  source              = "./vpc"
  name                = var.name
  cidr                = var.cidr
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  availability_zones  = var.availability_zones
  container_port      = var.container_port
  environment         = var.environment
}

module "efs" {
  source              = "./efs"
  name                = var.name
  private_subnets     = module.vpc.private_subnets
  vpc_id              = module.vpc.id
  environment         = var.environment
}

module "alb" {
  source              = "./alb"
  name                = var.name
  vpc_id              = module.vpc.id
  subnets             = module.vpc.public_subnets
  environment         = var.environment
  alb_security_groups = [ module.vpc.alb ]
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
  ecs_service_security_groups = [ module.vpc.ecs_tasks ]
  efs_id                      = module.efs.id
  efs_ap_id                   = module.efs.ap_id
  container_image             = var.container_image
  container_port              = var.container_port
  container_cpu               = var.container_cpu
  container_memory            = var.container_memory
  service_desired_count       = var.service_desired_count
  container_environment       = [{
        name  = "WORDPRESS_DATABASE_HOST"
        value = module.rds.db
    },{
        name  = "WORDPRESS_DATABASE_NAME"
        value = var.db_name
    },{
        name  = "WORDPRESS_DATABASE_USER"
        value = var.db_username
    },{
        name  = "WORDPRESS_DATABASE_PASSWORD"
        value = var.db_password
    },{
        name  = "ALLOW_EMPTY_PASSWORD"
        value = "true"
  }]
}