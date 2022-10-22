resource "aws_efs_file_system" "main" {
  creation_token = "wordpress-efs"
}

resource "aws_efs_access_point" "main" {
  file_system_id = aws_efs_file_system.main.id

  posix_user {
    gid = 1001
    uid = 1001
  }
  
  root_directory {
    path = "/bitnami/wordpress"
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = 0777
    }
  }
}

resource "aws_efs_mount_target" "main" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = "subnet-02caf3f4a7dab08f6"
  security_groups = [ aws_security_group.efs.id ]
}

# resource "aws_efs_file_system_policy" "policy" {
#   file_system_id = aws_efs_file_system.main.id
#   policy = <<POLICY
# {
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "*"
#             },
#             "Action": [
#                 "elasticfilesystem:*"
#             ],
#             "Resource": "${aws_efs_file_system.main.arn}",
#             "Condition": {
#                 "Bool": {
#                     "aws:SecureTransport": "true"
#                 },
#                 "StringEquals": {
#                     "elasticfilesystem:AccessPointArn" : "${aws_efs_access_point.main.arn}"
#                 }
#             }
#         }
#     ]
# }
# POLICY
# }


resource "aws_security_group" "efs" {
  name        = "${local.name}-sg-efs"
  description = "Allow EFS inbound traffic from VPC"
  vpc_id      = local.vpc_id

  ingress {
    description      = "NFS traffic from VPC"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    security_groups  = [aws_security_group.tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}