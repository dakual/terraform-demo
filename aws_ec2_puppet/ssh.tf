// Generate the SSH keypair that we’ll use to configure the EC2 instance.
// After that, write the private key to a local file and upload the public key to AWS
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  filename        = "${var.key_name}.pem"
  content         = tls_private_key.key.private_key_pem
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.key_name}"
  public_key = tls_private_key.key.public_key_openssh
}
