resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.service_name}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = {
    Name        = "${var.service_name}-igw"
    Environment = var.environment
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.service_name}-rtb-public"
    Environment = var.environment
  }
}

# 0.0.0.0/0 -> IGW
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public_subnet" {
  for_each          = toset(var.az_names)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(var.az_names, each.value))
  availability_zone = each.value

  tags = {
    // default tag로 묶어도 좋을듯
    Name        = "${var.service_name}-public-${each.value}"
    Environment = var.environment
  }
}

# NAT Gateway for outbound internet access from private subnets
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.service_name}-nat-eip"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[var.az_names[0]].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name        = "${var.service_name}-nat-gw"
    Environment = var.environment
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.service_name}-rtb-private"
    Environment = var.environment
  }
}

# 0.0.0.0/0 -> NAT Gateway for private subnets
resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "web_private_association" {
  for_each       = aws_subnet.web_private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "was_private_association" {
  for_each       = aws_subnet.was_private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "web_private_subnet" {
  for_each          = toset(var.az_names)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 100 + index(var.az_names, each.value))
  availability_zone = each.value

  tags = {
    Name        = "${var.service_name}-web-private-subnet-${each.value}"
    Environment = var.environment
  }
}

resource "aws_subnet" "was_private_subnet" {
  for_each          = toset(var.az_names)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 110 + index(var.az_names, each.value))
  availability_zone = each.value

  tags = {
    Name        = "${var.service_name}-was-private-subnet-${each.value}"
    Environment = var.environment
  }
}

resource "aws_subnet" "db_private_subnet" {
  for_each          = toset(var.az_names)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 120 + index(var.az_names, each.value))
  availability_zone = each.value

  tags = {
    Name        = "${var.service_name}-db-private-subnet-${each.value}"
    Environment = var.environment
  }
}

