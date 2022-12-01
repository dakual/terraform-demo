################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = var.cluster_name
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway   = true
  single_nat_gateway   = true

  enable_vpn_gateway   = false

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.3"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t2.small", "t2.medium", "t3.small", "t3.medium"]
  }

  eks_managed_node_groups = {
    initial = {
      min_size     = 1
      max_size     = 10
      desired_size = 2

      create_security_group = false
      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"
    }
  }

  # create_aws_auth_configmap = true 
  # manage_aws_auth_configmap = true

  # aws_auth_users = [
  #   {
  #     userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  #     username = "root"
  #     groups   = ["system:masters"]
  #   }
  # ]

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}

data "aws_caller_identity" "current" {}