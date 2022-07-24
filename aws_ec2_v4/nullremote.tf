resource "null_resource" "nullremote"  {
  depends_on = [
    aws_volume_attachment.ebs_att,aws_cloudfront_distribution.s3_distribution
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
      "sudo apt update",
      "sudo apt install nginx -y",
      "sudo mkfs.ext4 /dev/xvdf",
      "sudo mount /dev/xvdf /mnt"
    ]
  }
}