# my local variables. you must change them for your infrastrucre settings.
# for example region, vpcid, subnet
locals {
  region  = "eu-central-1"
  vpc_id  = "vpc-064f43e135e1ecbc0"
  subnets = ["subnet-02caf3f4a7dab08f6", "subnet-0e00855f4313be466", "subnet-0535e60978084785d"]
  cluster = "redacre-cluster"
  frontend_image = "public.ecr.aws/m2a7z1o1/frontend"
  backend_image  = "public.ecr.aws/m2a7z1o1/backend"
}

# i am creating cluster in here
resource "aws_ecs_cluster" "this" {
  name = local.cluster

  # this setting for cluster logging.
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# i am cretiand fargate cluster
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# i am creating taks. in this task we have 2 container. in this way, containers communicate
# eachothers.
resource "aws_ecs_task_definition" "this" {
  family                   = "tasks"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 1024

  # thses roles for cloudwatch and image registry
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = local.frontend_image
      cpu       = 10
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
    },
    {
      name      = "backend"
      image     = local.backend_image
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 5000
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

# i am creating a service for my task. this service will control our containers.
# if container down, the service schedule it and container will up again.
resource "aws_ecs_service" "this" {
  name            = "service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_lb_listener.this]

  # in here i am define container networks and security group. also i define public ip.
  network_configuration {
    subnets          = [for subnet in local.subnets : subnet]
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = true
  }

  # i define loadbalance because it will redirect requests from loadbalancer to frontend
  # container.
  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "frontend"
    container_port   = 80
  }
}

# these are opening cloudwatch group. actualy we can open log group in the 'logConfiguration'
# we can add "awslogs-create-group": "true", this section. but also we need to create an iam policy
resource "aws_cloudwatch_log_group" "yada1" {
  name = "ecs/backend"
}
resource "aws_cloudwatch_log_group" "yada2" {
  name = "ecs/frontend"
}