resource "aws_instance" "nat_instance" {
  ami           = var.nat_ami
  instance_type = var.nat_instance_type
  #   subnet_id     = aws_subnet.public_subnet_a.id
  network_interface {
    network_interface_id = aws_network_interface.nat_interface.id
    device_index         = 0
  }
  key_name = aws_key_pair.nat_key.key_name

  tags = {
    name = "nat_instance"
  }
}

resource "aws_eip" "nat_ip" {
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip_association" "nat_ip_association" {
  instance_id   = aws_instance.nat_instance.id
  allocation_id = aws_eip.nat_ip.id
}

resource "aws_instance" "private_instance" {
  ami           = var.ec2_ami
  instance_type = var.nat_instance_type
  subnet_id     = aws_subnet.private_subnet_a.id
  key_name      = aws_key_pair.nat_key.key_name

  security_groups = [aws_security_group.private_security_group.id]

  tags = {
    name = "private_instance"
  }
}
