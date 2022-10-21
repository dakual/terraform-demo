locals {
  name            = "demo-app"
  environment     = "dev"
  region          = "eu-central-1"
  vpc_id          = "vpc-064f43e135e1ecbc0"
  subnets         = ["subnet-02caf3f4a7dab08f6"]
  sgroups         = ["sg-095938d5e717361ea"]
  frontend_image  = "kurtay/php-frontend"
  backend_image   = "kurtay/php-backend"
  container_port  = 80
  db_username     = "demo"
  db_password     = "12345678"
  db_name         = "demo"
}

resource "aws_iam_role" "execution" {
  name = "${local.name}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "task" {
  name = "${local.name}-ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "a1" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
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
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${local.frontend_image}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [{
          protocol      = "tcp"
          containerPort = local.container_port
          hostPort      = local.container_port
      }]
      environment = [{
          name  = "API_HOST"
          value = "http://localhost:5000"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name      = "backend"
      image     = "${local.backend_image}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      environment = [{
          name  = "DB_HOST"
          value = aws_db_instance.this.address
      },{
          name  = "DB_NAME"
          value = local.db_name
      },{
          name  = "DB_USER"
          value = local.db_username
      },{
          name  = "DB_PASS"
          value = local.db_password
      }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
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

resource "aws_db_instance" "this" {
  identifier           = "${local.name}-db-${local.environment}"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = local.db_name
  username             = local.db_username
  password             = local.db_password
  skip_final_snapshot  = true
}

# data "aws_network_interface" "bar" {
#   # count = "${length(local.subnets)}"

#   filter {
#     name   = "group-id"
#     values = [aws_security_group.tasks.id]
#   }

#   filter {
#     name   = "vpc-id"
#     values = [local.vpc_id]
#   }

#   filter {
#     name   = "subnet-id"
#     values = local.subnets
#   }
# }

# output "public_ip" {
#   value = data.aws_network_interface.bar.association.*.public_ip
# }

# output "public_dns_name" {
#   value = data.aws_network_interface.bar.association.*.public_dns_name
# }

output "rds_hostname" {
  description = "RDS instance hostname"
  value = aws_db_instance.this.address
}

output "rds_port" {
  description = "RDS instance port"
  value = aws_db_instance.this.port
}
