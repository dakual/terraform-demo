data "aws_caller_identity" "aws_id" {}

resource "aws_iam_role" "ec2" {
  name = "beanstalk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "svc" {
  name = "beanstalk-svc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "beanstalk-instance-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_iam_instance_profile" "svc" {
  name = "beanstalk-instance-profile"
  role = aws_iam_role.svc.name
}

# resource "aws_s3_bucket" "beanstalk" {
#   bucket = "${var.application_name}-${data.aws_caller_identity.aws_id.account_id}"
#   force_destroy = true

#   tags = {
#     Name = "${var.application_name} bucket"
#   }  
# }

# resource "aws_s3_object" "beanstalk" {
#   bucket = aws_s3_bucket.beanstalk.id
#   key    = "beanstalk/php-v1.zip"
#   source = "php-v1.zip"
# }

# resource "aws_elastic_beanstalk_application_version" "default" {
#   name        = "php-app-v1"
#   application = var.application_name
#   description = "application version created by terraform"
#   bucket      = aws_s3_bucket.beanstalk.id
#   key         = aws_s3_object.beanstalk.id
# }

resource "aws_elastic_beanstalk_application" "app" {
  name = var.application_name
}

resource "aws_elastic_beanstalk_environment" "devenv" {
  name                ="${var.application_name}-Api"
  application         = aws_elastic_beanstalk_application.app.name
  # solution_stack_name = "64bit Amazon Linux 2 v3.3.2 running Corretto 11"
  solution_stack_name = "64bit Amazon Linux 2 v3.4.1 running PHP 8.1"
  tier                = "WebServer"
  tags = {
      App_Name = var.application_name
      Environment = "test"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.ec2.name}"
    # value     =  "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${aws_iam_instance_profile.svc.name}"
    # value     = "aws-elasticbeanstalk-service-role"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", sort(var.vpc_subnets))
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SSHSourceRestriction"
    value     = "tcp, 22, 22, ${var.vpc_cidr}"
  } 
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.ssh_key}"
  }
}