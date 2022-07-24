resource "aws_ecs_cluster" "production" {
  lifecycle {
    create_before_destroy = true
  }

  name = "production"

  tags = {
    Env  = "production"
    Name = "production"
  }
}

resource "aws_ecs_task_definition" "default" {
  family                   = "Test"
  requires_compatibilities = ["EC2"]
  network_mode             = "host"
  memory                   = 500

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${var.image_name}:latest"
      cpu       = 256
      essential = true

      portMappings = [
        { "containerPort": 5000, "protocol": "tcp" }
      ]

      environment = [
        { "name": "MESSAGE", "value": "Hello World!" }
      ]

      command = ["bundle", "exec", "rackup", "-p", "8080", "-E", "production"],
    }
  ])
}

resource "aws_ecs_service" "default" {
  cluster                 = aws_ecs_cluster.production.id
  depends_on              = [aws_iam_role_policy_attachment.ecs]
  desired_count           = 1
  enable_ecs_managed_tags = true
  force_new_deployment    = true

  load_balancer {
    target_group_arn = aws_alb_target_group.default.arn
    container_name   = "app"
    container_port   = 5000
  }

  name            = "blog"
  task_definition = "${aws_ecs_task_definition.default.family}:${data.aws_ecs_task_definition.default.revision}"
}

