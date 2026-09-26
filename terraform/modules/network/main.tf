# VPCs

resource "aws_vpc" "primary" {
  cidr_block           = var.primary_vpc_cidr
  enable_dns_hostnames = true
}

resource "aws_vpc" "secondary" {
  cidr_block           = var.secondary_vpc_cidr
  enable_dns_hostnames = true
}

resource "aws_vpc_peering_connection" "primary_secondary" {
  peer_vpc_id = aws_vpc.primary.id
  vpc_id      = aws_vpc.secondary.id
  auto_accept = true
}

# Internet gateways

resource "aws_internet_gateway" "primary" {
  vpc_id = aws_vpc.primary.id
}

resource "aws_internet_gateway" "secondary" {
  vpc_id = aws_vpc.secondary.id
}

# Subnets públicas e privadas

resource "aws_subnet" "primary_public" {
  vpc_id                  = aws_vpc.primary.id
  availability_zone       = var.availability_zones[0]
  cidr_block              = var.primary_public_subnet_cidr
  map_public_ip_on_launch = true
}

resource "aws_subnet" "secondary_public" {
  vpc_id                  = aws_vpc.secondary.id
  availability_zone       = var.availability_zones[0]
  cidr_block              = var.secondary_public_subnet_cidr
  map_public_ip_on_launch = true
}

resource "aws_subnet" "primary_private" {
  vpc_id                  = aws_vpc.primary.id
  availability_zone       = var.availability_zones[1]
  cidr_block              = var.primary_private_subnet_cidr
  map_public_ip_on_launch = false
}

resource "aws_subnet" "secondary_private" {
  vpc_id                  = aws_vpc.secondary.id
  availability_zone       = var.availability_zones[1]
  cidr_block              = var.secondary_private_subnet_cidr
  map_public_ip_on_launch = false
}

# NAT gateways (saída para a internet das subnets privadas)

resource "aws_eip" "nat_primary" {}

resource "aws_eip" "nat_secondary" {}

resource "aws_nat_gateway" "primary" {
  allocation_id = aws_eip.nat_primary.id
  subnet_id     = aws_subnet.primary_public.id
}

resource "aws_nat_gateway" "secondary" {
  allocation_id = aws_eip.nat_secondary.id
  subnet_id     = aws_subnet.secondary_public.id
}

# Tabelas de rotas

resource "aws_route_table" "primary_public" {
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary.id
  }
  route {
    cidr_block = var.secondary_vpc_cidr
    gateway_id = aws_vpc_peering_connection.primary_secondary.id
  }
}

resource "aws_route_table" "secondary_public" {
  vpc_id = aws_vpc.secondary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary.id
  }
  route {
    cidr_block = var.primary_vpc_cidr
    gateway_id = aws_vpc_peering_connection.primary_secondary.id
  }
}

resource "aws_route_table" "primary_private" {
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.primary.id
  }
  route {
    cidr_block = var.secondary_vpc_cidr
    gateway_id = aws_vpc_peering_connection.primary_secondary.id
  }
}

resource "aws_route_table" "secondary_private" {
  vpc_id = aws_vpc.secondary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.secondary.id
  }
  route {
    cidr_block = var.primary_vpc_cidr
    gateway_id = aws_vpc_peering_connection.primary_secondary.id
  }
}

# Associação das subnets às tabelas de rotas

resource "aws_route_table_association" "primary_public" {
  subnet_id      = aws_subnet.primary_public.id
  route_table_id = aws_route_table.primary_public.id
}

resource "aws_route_table_association" "secondary_public" {
  subnet_id      = aws_subnet.secondary_public.id
  route_table_id = aws_route_table.secondary_public.id
}

resource "aws_route_table_association" "primary_private" {
  subnet_id      = aws_subnet.primary_private.id
  route_table_id = aws_route_table.primary_private.id
}

resource "aws_route_table_association" "secondary_private" {
  subnet_id      = aws_subnet.secondary_private.id
  route_table_id = aws_route_table.secondary_private.id
}
