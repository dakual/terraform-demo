terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.38.0"
    }
  }
}

provider "aws" {
  region = local.region
}

locals {
  name            = "demo-app"
  environment     = "dev"
  region          = "eu-central-1"
  vpc_id          = "vpc-0321d67fee12e82d7"
  private_subnets = ["subnet-061181188eefd9a7e", "subnet-08320941b26867cb4"]
  # ELB Listener ARN
  integration_uri = "arn:aws:elasticloadbalancing:eu-central-1:632296647497:listener/net/adb77766d0d504648a38bb97b9ba92dd/ae4e4d1cc4d00f7e/ebdd430ff261f378"
}


resource "aws_apigatewayv2_api" "main" {
  name          = "${local.name}-api-gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "main" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "${local.name}-dev"
  auto_deploy = true
}

resource "aws_security_group" "vpc_link" {
  name   = "${local.name}-vpc-link-sg"
  vpc_id = local.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_apigatewayv2_vpc_link" "eks" {
  name               = "${local.name}-eks-link"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids         = local.private_subnets
}

resource "aws_apigatewayv2_integration" "eks" {
  api_id = aws_apigatewayv2_api.main.id

  integration_uri    = local.integration_uri
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.eks.id
}

resource "aws_apigatewayv2_route" "echo" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.eks.id}"
}

output "api-url" {
  value = "${aws_apigatewayv2_stage.main.invoke_url}/"
}