# these are iam role and policies. We added because cloudwatch logging and image download.
# Actualiy we do not need policy for image download because i open all ports from security group.
resource "aws_iam_role" "this" {
  name               = "execution-task-role"
  assume_role_policy = data.this.assume_role_policy.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExtecutionRole_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}