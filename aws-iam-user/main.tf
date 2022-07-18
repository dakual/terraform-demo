resource "aws_iam_group_membership" "team" {
  name = "tf-testing-group-membership"

  users = [
    aws_iam_user.user.name
  ]

  group = aws_iam_group.group.name
}

resource "aws_iam_group" "group" {
  name = "devops-group"
}

resource "aws_iam_group_policy" "group_policy" {
  name  = "developer_policy"
  group = aws_iam_group.group.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user" "user" {
  name = "terraform-user"

  tags = {
    env = "dev"
  }
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
  pgp_key = var.pgp_key
}

resource "aws_iam_user_policy" "user_role" {
  name = "test"
  user = aws_iam_user.user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_login_profile" "profile" {
  user    = aws_iam_user.user.name
  pgp_key = var.pgp_key
}


resource "aws_iam_user_ssh_key" "user_ssh_key" {
  username   = aws_iam_user.user.name
  encoding   = "SSH"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCBz3n69Rbf32ILGsFwpc/N6XH7xgyHWtig6TvrgAuLaJyb53EBUuuG1DirICOXIoBQq1yGtsoVhMQVVBUKp41VbHDaNLcMC3tt+nj5VMv8RE/nLuDkiI+1iJYPgZbKRF1/Qzyei77B5k+BznaRUPqjnJSzSunjvuEqCjcH2fPQjlTT68+apzq0SIhuedXSkd9svrWENjvw37HvDU4MOUshZJyLvKAXAuTZA7yZOSrPkyAfO6o5bBICGjxOCeoQcgphk3u4FvnfD+k7ToHnWj28/LqPWguFywTjzZiZ+pmDJ6CzWuwJ0r8l2VrQJ4uP5QFntkr10PzpTYqe+iB2LPsN"
}

output "profile_arn" {
  value = aws_iam_user.user.arn
}

output "profile_password" {
  value = aws_iam_user_login_profile.profile.password
}

output "access_key_id" {
  value = aws_iam_access_key.user.id
}

output "access_key_secret" {
  value = nonsensitive(aws_iam_access_key.user.secret)
}

output "ssh_key" {
  value = aws_iam_user_ssh_key.user_ssh_key.public_key
}