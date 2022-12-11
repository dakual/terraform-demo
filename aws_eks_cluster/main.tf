locals {
  name                = "test"
  environment         = "dev"
  region              = "eu-central-1"
  cidr                = "10.0.0.0/16"
  availability_zones  = ["${local.region}a", "${local.region}b"]
  private_subnets     = ["10.0.0.0/20", "10.0.16.0/20"]
  public_subnets      = ["10.0.32.0/20", "10.0.64.0/20"]
  cluster_name        = "test"
  cluster_version     = "1.24"
  cluster_ip_family   = "ipv4"
}

data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_id
}

################################################################################
# VPC Module
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name                 = local.name
  cidr                 = local.cidr
  azs                  = local.availability_zones
  private_subnets      = local.private_subnets
  public_subnets       = local.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

################################################################################
# EKS Module
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.26.6"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_name      = local.cluster_name
  cluster_version   = local.cluster_version
  cluster_ip_family = local.cluster_ip_family

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true

  eks_managed_node_group_defaults = {
    disk_size      = 20
    instance_types = ["t2.medium", "t3.small", "t3.medium"]
    capacity_type  = "SPOT"
  }

  eks_managed_node_groups = {
    initial = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      create_security_group  = false
      create_launch_template = false
      launch_template_name   = ""

      remote_access = {
        ec2_ssh_key               = aws_key_pair.node.key_name
        source_security_group_ids = [aws_security_group.node.id]
      }
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::632296647497:root"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Name        = local.cluster_name
    Environment = local.environment
  }
}


resource "aws_key_pair" "node" {
  key_name   = "${local.cluster_name}-node"
  public_key = file("${path.module}/files/node.pub")
}

resource "aws_security_group" "node" {
  name   = "${local.cluster_name}-node-sg"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}