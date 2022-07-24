data "aws_availability_zones" "available" {}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}