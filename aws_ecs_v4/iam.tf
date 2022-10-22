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
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "a1" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# resource "aws_iam_role_policy_attachment" "a3" {
#   role       = aws_iam_role.execution.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "a2" {
#   role       = aws_iam_role.task.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
# }