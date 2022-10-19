locals {
  region  = "eu-central-1"
  vpc_id  = "vpc-064f43e135e1ecbc0"
  subnets = ["subnet-02caf3f4a7dab08f6", "subnet-0e00855f4313be466", "subnet-0535e60978084785d"]
  cluster = "my-cluster"
  frontend_image = "public.ecr.aws/m2a7z1o1/frontend:latest"
  backend_image  = "public.ecr.aws/m2a7z1o1/backend:latest"
}

resource "aws_ecs_cluster" "this" {
  name = local.cluster

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = local.frontend_image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],
      "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "ecs/frontend",
        "awslogs-region": local.region,
        "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_lb_listener.this]

  network_configuration {
    subnets          = [for subnet in local.subnets : subnet]
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "frontend"
    container_port   = 80
  }

  tags = {
    env = "dev"
  }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = local.backend_image
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ],
      "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "ecs/backend",
        "awslogs-region": local.region,
        "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ])
}



resource "aws_ecs_service" "backend" {
  name            = "backend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for subnet in local.subnets : subnet]
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "backend"
    container_port   = 5000
  }

  tags = {
    env = "dev"
  }
}

resource "aws_cloudwatch_log_group" "yada1" {
  name = "ecs/backend"
}

resource "aws_cloudwatch_log_group" "yada2" {
  name = "ecs/frontend"
}