#Create a new EC2 launch configuration
resource "aws_instance" "ec2_public" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.ssh-security-group.id}"]
  subnet_id                   = "${aws_subnet.public-subnet-1.id}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = "EC2-PUBLIC"
  }

  # # Copies the ssh key file to home dir
  # provisioner "file" {
  #   source      = "./${var.key_name}.pem"
  #   destination = "/home/ec2-user/${var.key_name}.pem"

  #   connection {
  #     type        = "ssh"
  #     user        = "admin"
  #     private_key = file("${var.key_name}.pem")
  #     host        = self.public_ip
  #     timeout     = "1m"
  #     agent       = false
  #   }
  # }

  # //chmod key 400 on EC2 instance
  # provisioner "remote-exec" {
  #   inline = ["chmod 400 ~/${var.key_name}.pem"]

  #   connection {
  #     type        = "ssh"
  #     user        = "admin"
  #     private_key = file("${var.key_name}.pem")
  #     host        = self.public_ip
  #     timeout     = "1m"
  #     agent       = false
  #   }
  # }
}

#Create a new EC2 launch configuration
resource "aws_instance" "ec2_private" {
  #name_prefix                 = "terraform-example-web-instance"
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.webserver-security-group.id}"]
  subnet_id                   = "${aws_subnet.private-subnet-1.id}"
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = "EC2-Private"
  }
}