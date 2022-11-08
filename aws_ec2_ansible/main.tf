locals {
  name             = "demo"
  region           = "eu-central-1"
  vpc_id           = "vpc-064f43e135e1ecbc0"
  subnet_id        = "subnet-02caf3f4a7dab08f6"
  ami              = "ami-0a5b5c0ea66ec560d"
  ssh_user         = "admin"
  key_name         = "mykey"
  private_key_path = "~/.aws/pems/mykey.pem"
}

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

resource "aws_security_group" "nginx" {
  name   = "${local.name}-nginx"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = local.ami
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }
  
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} playbook.yml"
  }
}

output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}