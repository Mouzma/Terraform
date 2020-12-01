provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

#vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags={
    Name = "terraform"
  }
}

# public subnets
resource "aws_subnet" "pub_subnet_1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
    tags={
    Name = "pub-1a"
  }
}

resource "aws_subnet" "pub_subnet_1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
      tags={
    Name = "pub-1b"
  }
}

# private subnets
resource "aws_subnet" "prv_subnet_1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
      tags={
    Name = "prv-1a"
  }
}

resource "aws_subnet" "prv_subnet_1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
      tags={
    Name = "prv-1b"
  }
}

# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# public route table
resource "aws_route_table" "pub_route_table" {
  vpc_id = aws_vpc.main.id
}


# public route 
resource "aws_route" "pub_r" {
  route_table_id            = aws_route_table.pub_route_table.id
  gateway_id                = aws_internet_gateway.gw.id
  destination_cidr_block                = "0.0.0.0/0"
}

# public association
resource "aws_route_table_association" "pub_assoc" {
  route_table_id = aws_route_table.pub_route_table.id
  subnet_id     =  aws_subnet.pub_subnet_1a.id
}

# aws eip for nat
resource "aws_eip" "nat" {
}

# aws nat gateway
resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = aws_subnet.pub_subnet_1a.id
  allocation_id = aws_eip.nat.id
}

# private route table
resource "aws_route_table" "prv_route_table" {
  vpc_id = aws_vpc.main.id
}


# private route 
resource "aws_route" "prv_r" {
  route_table_id            = aws_route_table.prv_route_table.id
  nat_gateway_id            = aws_nat_gateway.nat_gw.id
  destination_cidr_block    = "0.0.0.0/0"
}

# private association
resource "aws_route_table_association" "prv_assoc" {
  route_table_id = aws_route_table.prv_route_table.id
  subnet_id = aws_subnet.prv_subnet_1a.id
}

