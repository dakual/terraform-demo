data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_ecs_cluster" "selected" {
  cluster_name = var.cluster_name
}

data "aws_security_group" "selected" {
  id = var.security_group_id
}


data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}
