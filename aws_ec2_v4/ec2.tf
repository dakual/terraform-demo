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
}