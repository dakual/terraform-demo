variable "awsprops" {
  type = map
  default = {
    region = "eu-central-1"
    vpc = "vpc-064f43e135e1ecbc0"
    ami = "ami-0a5b5c0ea66ec560d"
    itype = "t2.micro"
    subnet = "subnet-02caf3f4a7dab08f6"
    publicip = true
    keyname = "mykey"
    secgroupid = "sg-095938d5e717361ea"
  }
}



resource "aws_instance" "project-iac" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") 
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")

  vpc_security_group_ids = [
    lookup(var.awsprops, "secgroupid")
  ]

  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "debian"
    Managed = "IAC"
  }
}


output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}