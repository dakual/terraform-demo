# Master node user data template #
data "template_file" "master" {
  template = "${file("./master_userdata.tpl")}"

  vars = {
    master_hostname = "${var.puppet_mastername}"
    puppet_repo     = "${var.puppet_repository}"
  }
}

# # Agent node user data template #
# data "template_file" "agent" {
#   template = "${file("./agent_userdata.tpl")}"

#   vars = {
#     master_hostname = "${var.puppet_mastername}"
#     agent_hostname  = "${var.puppet_agentname}"
#   }
# }

#Create a new EC2 Puppet master launch configuration
resource "aws_instance" "master" {
  ami                         = "ami-048df70cfbd1df3a9"
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.key_pair.key_name
  user_data                   = data.template_file.master.rendered
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = var.puppet_mastername
  }
}

# #Create a new EC2 Puppet node-1 launch configuration
# resource "aws_instance" "agent" {
#   ami                         = "ami-048df70cfbd1df3a9"
#   instance_type               = "t2.micro"
#   key_name                    = aws_key_pair.key_pair.key_name
#   user_data                   = data.template_file.agent.rendered
#   associate_public_ip_address = true

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     "Name" = var.puppet_agentname
#   }
# }

resource "null_resource" "master" {
  depends_on = [
    aws_instance.master#,aws_instance.agent
  ]

  connection {
    type    = "ssh"
    user    = "admin"
    host    = aws_instance.master.public_ip
    port    = 22
    private_key = tls_private_key.key.private_key_pem
    agent       = false
  }  

  provisioner "remote-exec" {
    inline = [
      "sudo /bin/sh -c 'echo \"${format("%s %s", aws_instance.master.private_ip, aws_instance.master.tags.Name)}\" >> /etc/hosts'",
#      "sudo /bin/sh -c 'echo \"${format("%s %s", aws_instance.agent.private_ip, aws_instance.agent.tags.Name)}\" >> /etc/hosts'"
    ]
  }
}

# resource "null_resource" "agent" {
#   depends_on = [
#     aws_instance.master,aws_instance.agent
#   ]

#   connection {
#     type    = "ssh"
#     user    = "admin"
#     host    = aws_instance.agent.public_ip
#     port    = 22
#     private_key = tls_private_key.key.private_key_pem
#   }  

#   provisioner "remote-exec" {
#     inline = [
#       "sudo /bin/sh -c 'echo \"${format("%s %s", aws_instance.master.private_ip, aws_instance.master.tags.Name)}\" >> /etc/hosts'",
#       "sudo /bin/sh -c 'echo \"${format("%s %s", aws_instance.agent.private_ip, aws_instance.agent.tags.Name)}\" >> /etc/hosts'"
#     ]
#   }
# }