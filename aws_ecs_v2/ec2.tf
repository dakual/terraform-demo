resource "aws_security_group" "ec2" {
  name = "security-group--ec2"
  vpc_id = aws_vpc.default.id
  description = "security-group--ec2"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    from_port       = 0
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    to_port         = 65535
  }

  tags = {
    Env  = "production"
    Name = "security-group--ec2"
  }
}

resource "aws_launch_configuration" "default" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  image_id                    = data.aws_ami.default.id
  instance_type               = "t3.micro"
  key_name                    = var.key_name
  security_groups             = [aws_security_group.ec2.id]
  user_data                   = file("user_data.sh")
  name_prefix                 = "lauch-configuration-"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
}

resource "aws_autoscaling_group" "default" {
  desired_capacity     = 1
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.default.name
  max_size             = 2
  min_size             = 1
  name                 = "auto-scaling-group"
  target_group_arns    = [aws_alb_target_group.default.arn]
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = aws_subnet.private_subnet.*.id
  
  tag {
    key                 = "Env"
    propagate_at_launch = true
    value               = "production"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "blog"
  }
}