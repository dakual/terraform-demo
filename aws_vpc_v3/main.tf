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
  name            = "demo-app"
  environment     = "dev"
  region          = "eu-central-1"
  container_image = "nginx:latest"
  container_port  = 80
}

module "vpc" {
  source              = "./vpc"
  name                = local.name
  environment         = local.environment
  cidr                = "10.0.0.0/16"
  private_subnets     = ["10.0.0.0/20", "10.0.32.0/20"]
  public_subnets      = ["10.0.16.0/20", "10.0.48.0/20"]
  availability_zones  = ["eu-central-1a", "eu-central-1b"]
}

resource "aws_security_group" "main" {
  name        = "${local.name}-sg"
  description = "Allow all inbound and outbound traffic"
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


# APPLICATION LOADBALANCER
resource "aws_lb" "main" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = module.vpc.public_subnets.*.id
}

resource "aws_alb_target_group" "main" {
  name        = "${local.name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type = "forward"
  }
}


# AIM ROLE
data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name = "${local.name}-ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_execution_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS CLUSTER, SERVICE AND TASK
resource "aws_cloudwatch_log_group" "task" {
  name = "/ecs/${local.name}-task"
}

resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${local.name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn

  container_definitions = jsonencode([{
      name  = "${local.name}-container"
      image = "${local.container_image}"
      essential = true
      environment = [{
          name  = "ENV_MESSAGE"
          value = "DEMO APP"
      }]
      portMappings = [{
          protocol = "tcp"
          containerPort = local.container_port
          hostPort = local.container_port
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.task.name
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
        }
      }
  }])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "main" {
  name                               = "${local.name}-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.main.id]
    subnets          = module.vpc.private_subnets.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = "${local.name}-container"
    container_port   = local.container_port
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

output "lb_dns_name" {
  value = aws_lb.main.dns_name
}
