# data.aws_vpc.selected.id
# data.aws_ecs_cluster.selected.id
# data.aws_security_group.selected.id


# output "key_name" {
#   value = data.aws_subnets.selected.ids
#   #value = ["${data.aws_subnet.selected.*.id}"]
#   # value = toset([
#   #   for subnet in data.aws_subnet.selected : subnet.id
#   # ])
# }


resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = data.aws_ecs_cluster.selected.id
  task_definition = aws_ecs_task_definition.test.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_lb_listener.hello_world]

  network_configuration {
    security_groups = [data.aws_security_group.selected.id]
    subnets         = data.aws_subnets.selected.ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.hello_world.id
    container_name   = "py-app"
    container_port   = 5000
  }
}

resource "aws_ecs_task_definition" "test" {
  family                   = "Test"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = "arn:aws:iam::632296647497:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "py-app"
      image     = "${var.image_name}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      environment = [
        {
          "name" : "TEST_ENV",
          "value" : "Hello World"
        }
      ]
    }
  ])
}


