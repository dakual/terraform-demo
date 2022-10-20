locals {
  name            = "demo-fs"
  environment     = "dev"
  region          = "eu-central-1"
  vpc_id          = "vpc-064f43e135e1ecbc0"
  subnet          = "subnet-02caf3f4a7dab08f6"
}

# Creating Amazon EFS File system
resource "aws_efs_file_system" "myfilesystem" {
  # encrypted = true

# Creating the AWS EFS lifecycle policy
# Amazon EFS supports two lifecycle policies. Transition into IA and Transition out of IA
# Transition into IA transition files into the file systems's Infrequent Access storage class
# Transition files out of IA storage
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${local.name}-efs-${local.environment}"
  }
}

# Creating the EFS access point for AWS EFS File system
resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.myfilesystem.id
}

# Creating the AWS EFS System policy to transition files into and out of the file system.
resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.myfilesystem.id
# The EFS System Policy allows clients to mount, read and perform write operations on File system 
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Policy01",
    "Statement": [
        {
            "Sid": "Statement",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.myfilesystem.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
POLICY
}

# Creating the AWS EFS Mount point in a specified Subnet 
resource "aws_efs_mount_target" "alpha" {
  file_system_id = aws_efs_file_system.myfilesystem.id
  subnet_id      = local.subnet
}