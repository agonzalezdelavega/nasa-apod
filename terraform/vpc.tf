# VPC

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "${local.prefix}-main"
  }
}

resource "aws_subnet" "public-2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}a"
  tags = {
    Name = "${local.prefix}-public-2a"
  }
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_subnet" "public-2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}b"
  tags = {
    Name = "${local.prefix}-public-2b"
  }
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_subnet" "private-2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_region.current.name}a"
  tags = {
    Name = "${local.prefix}-private-2a"
  }
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_subnet" "private-2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_region.current.name}b"
  tags = {
    Name = "${local.prefix}-private-2b"
  }
  depends_on = [
    aws_vpc.main
  ]
}

# IGW + NATs

resource "aws_internet_gateway" "igw-main" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${local.prefix}-igw"
  }
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_eip" "eip-2a" {}

resource "aws_eip" "eip-2b" {}

resource "aws_nat_gateway" "nat-2a" {
  subnet_id     = aws_subnet.public-2a.id
  allocation_id = aws_eip.eip-2a.id
  depends_on = [
    aws_subnet.public-2a,
    aws_eip.eip-2a
  ]
}

resource "aws_nat_gateway" "nat-2b" {
  subnet_id     = aws_subnet.public-2b.id
  allocation_id = aws_eip.eip-2b.id
  depends_on = [
    aws_subnet.public-2b,
    aws_eip.eip-2b
  ]
}

# Route Tables

resource "aws_route_table" "route-table-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-main.id
  }
}

resource "aws_route_table" "route-table-private-2a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-2a.id
  }
}

resource "aws_route_table" "route-table-private-2b" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-2b.id
  }
}

resource "aws_route_table_association" "route-table-association-public-2a" {
  subnet_id      = aws_subnet.public-2a.id
  route_table_id = aws_route_table.route-table-public.id
}

resource "aws_route_table_association" "route-table-association-public-2b" {
  subnet_id      = aws_subnet.public-2b.id
  route_table_id = aws_route_table.route-table-public.id
}

resource "aws_route_table_association" "route-table-association-private-2a" {
  subnet_id      = aws_subnet.private-2a.id
  route_table_id = aws_route_table.route-table-private-2a.id
}

resource "aws_route_table_association" "route-table-association-private-2b" {
  subnet_id      = aws_subnet.private-2b.id
  route_table_id = aws_route_table.route-table-private-2b.id
}