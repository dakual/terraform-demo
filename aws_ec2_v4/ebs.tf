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