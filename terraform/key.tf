resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nat_key" {
  key_name   = "ec2_key"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.nat_key.key_name}.pem"
  content  = tls_private_key.private_key.private_key_pem
}
