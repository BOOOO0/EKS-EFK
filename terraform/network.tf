resource "aws_vpc" "mento_vpc" {
  cidr_block = var.mento_vpc_cidr_block

  tags = {
    Name = "mento-vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.mento_vpc.id
  cidr_block        = var.public_subnet_a_cidr_block
  availability_zone = var.az-a

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.mento_vpc.id
  cidr_block        = var.private_subnet_a_cidr_block
  availability_zone = var.az-a

  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.mento_vpc.id
  cidr_block        = var.public_subnet_b_cidr_block
  availability_zone = var.az-c

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.mento_vpc.id
  cidr_block        = var.private_subnet_b_cidr_block
  availability_zone = var.az-c

  tags = {
    Name = "private-subnet-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mento_vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.mento_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rtb"
  }
}

resource "aws_network_interface" "nat_interface" {
  subnet_id         = aws_subnet.public_subnet_a.id
  source_dest_check = false
  security_groups   = [aws_security_group.nat_instance_security_group.id]

  tags = {
    Name = "nat-instance-network-interface"
  }
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.mento_vpc.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.nat_interface.id
  }

  tags = {
    Name = "private-rtb"
  }
}

resource "aws_route_table_association" "public_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "public_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "private_a_association" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "private_b_association" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rtb.id
}
