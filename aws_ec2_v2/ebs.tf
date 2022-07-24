resource "aws_ebs_volume" "volume" {
  availability_zone = aws_instance.ec2_public.availability_zone
  size              = 1

  tags = {
    Name = "task1"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name   = "/dev/xvdf"
  volume_id     = aws_ebs_volume.volume.id
  instance_id   = aws_instance.ec2_public.id
  force_detach  = true 
  depends_on    = [ aws_ebs_volume.volume]
}

resource "null_resource" "nullremote"  {
  depends_on = [
    aws_volume_attachment.ebs_att
  ]

  connection {
    type    = "ssh"
    user    = "admin"
    host    = aws_instance.ec2_public.public_ip
    port    = 22
    private_key = tls_private_key.key.private_key_pem
  }

  provisioner "remote-exec" {
    inline  = [
      "sudo mkfs.ext4 /dev/xvdf",
      "sudo mount /dev/xvdf /mnt"
    ]
  }
}