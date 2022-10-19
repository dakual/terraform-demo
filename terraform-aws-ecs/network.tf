# I am creating security group for container and loadbalancer. 
# In this chalange i open all ports and i will use one security group.
# but it is not true way. always we must use different sc group and open ports what we need.
resource "aws_security_group" "this" {
  name        = "redacre-sc"
  description = "Allow All inbound and outbound traffic"
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
}


## we are creating application loadbalancer for our application.
resource "aws_lb" "this" {
  name               = "redacre-sc"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this.id]
  subnets            = [for subnet in local.subnets : subnet]

  tags = {
    Environment = "dev"
  }
}

# i am creatin lb group for listener. this group will handle http requests from listener.
resource "aws_lb_target_group" "this" {
  name        = "lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"
}

# we are listenin 80 port on the loadbancer and forwarding http request to lb group.
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
