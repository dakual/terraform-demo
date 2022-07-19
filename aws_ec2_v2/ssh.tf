// Generate the SSH keypair that we’ll use to configure the EC2 instance.
// After that, write the private key to a local file and upload the public key to AWS
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  filename        = "${var.key_name}.pem"
  content         = tls_private_key.key.private_key_pem
  #file_permission = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.key_name}"
  public_key = tls_private_key.key.public_key_openssh
}

# resource "tls_private_key" "pk" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "kp" {
#   key_name   = "myKey"       # Create "myKey" to AWS!!
#   public_key = tls_private_key.pk.public_key_openssh

#   provisioner "local-exec" { # Create "myKey.pem" to your computer!!
#     command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
#   }
# }