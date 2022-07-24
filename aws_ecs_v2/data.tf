data "aws_availability_zones" "available" {}

data "aws_iam_policy_document" "ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_ami" "default" {
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }

  most_recent = true
  owners      = ["amazon"]
}

data "aws_ecs_task_definition" "default" {
  task_definition = aws_ecs_task_definition.default.family
}

# data "aws_ecs_cluster" "production" {
#   cluster_name = var.cluster_name
# }