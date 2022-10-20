locals {
  name            = "demo-app"
  environment     = "dev"
  region          = "eu-central-1"
  vpc_id          = "vpc-064f43e135e1ecbc0"
  subnets         = ["subnet-02caf3f4a7dab08f6"]
  sgroups         = ["sg-095938d5e717361ea"]
  container_image = "public.ecr.aws/m2a7z1o1/frontend-app"
  container_port  = 8080
  role_arn        = "arn:aws:iam::632296647497:role/ecsTaskExecutionRole"
}

resource "aws_security_group" "tasks" {
  name   = "${local.name}-sg-task-${local.environment}"
  vpc_id = local.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = local.container_port
    to_port          = local.container_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${local.name}-task-${local.environment}"
}

resource "aws_ecs_cluster" "this" {
  name = "${local.name}-cluster-${local.environment}"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${local.name}-task-${local.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  # container_definitions = file("task-definitions/demo-app.json")
  container_definitions = jsonencode([{
      name      = "${local.name}-container-${local.environment}"
      image     = "${local.container_image}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [{
          protocol      = "tcp"
          containerPort = local.container_port
          hostPort      = local.container_port
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
        }
      }
  }])
}

resource "aws_ecs_service" "main" {
  name            = "${local.name}-service-${local.environment}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for subnet in local.subnets : subnet]
    security_groups  = [aws_security_group.tasks.id]
    assign_public_ip = true
  }
}

data "aws_network_interface" "bar" {
  # count = "${length(local.subnets)}"

  filter {
    name   = "group-id"
    values = [aws_security_group.tasks.id]
  }

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = local.subnets
  }
}

output "public_ip" {
  value = data.aws_network_interface.bar.association.*.public_ip
}

output "public_dns_name" {
  value = data.aws_network_interface.bar.association.*.public_dns_name
}