terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.5"
}

provider "aws" {
  region  = "eu-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-048df70cfbd1df3a9"
  instance_type = "t2.micro"

  # user_data = <<-EOF
  #             #!/bin/bash
  #             echo "Hello, World" > index.html
  #             nohup busybox httpd -f -p "${var.server_port}" &
  #             EOF

  # lifecycle {
  #   create_before_destroy = true
  # }

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
