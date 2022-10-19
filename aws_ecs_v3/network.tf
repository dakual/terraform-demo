resource "aws_security_group" "this" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "Allow HTTP for all"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   cidr_blocks = ["0.0.0.0/0"]
  #   from_port   = 0
  #   protocol    = "-1"
  #   to_port     = 0
  # }    
}

resource "aws_lb" "this" {
  name               = "test"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this.id]
  subnets            = [for subnet in local.subnets : subnet]

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "this" {
  name        = "lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}