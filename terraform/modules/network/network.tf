resource "aws_vpc" "vpc10" {
    cidr_block           = var.vpc10_feijao
    enable_dns_hostnames = true
}

resource "aws_vpc" "vpc20" {
    cidr_block           = var.vpc20_sazon
    enable_dns_hostnames = true
}

resource "aws_vpc_peering_connection" "vpc_peering" {
 peer_vpc_id = aws_vpc.vpc10.id
 vpc_id = aws_vpc.vpc20.id
 auto_accept = true
}

//INTERNET GATEWAY

resource "aws_internet_gateway" "igw10" {
    vpc_id = aws_vpc.vpc10.id
}

resource "aws_internet_gateway" "igw20" {
    vpc_id = aws_vpc.vpc20.id
}

// SUBNETS PUBLICAS E PRIVADAS

resource "aws_subnet" "sn_pub_az1a_vpc10" {
    vpc_id                  = aws_vpc.vpc10.id
    availability_zone       = "us-east-1a"
    cidr_block              = var.sub_pub_az1a_vpc10_cidr
    map_public_ip_on_launch = true
}

resource "aws_subnet" "sn_pub_az1a_vpc20" {
    vpc_id                  = aws_vpc.vpc20.id
    availability_zone       = "us-east-1a"
    cidr_block              = var.sub_pub_az1a_vpc20_cidr
    map_public_ip_on_launch = true
}

resource "aws_subnet" "sn_priv_az1c_vpc10" {
    vpc_id                  = aws_vpc.vpc10.id
    availability_zone       = "us-east-1c"
    cidr_block              = var.sub_priv_az1c_vpc10_cidr
    map_public_ip_on_launch = false
}

resource "aws_subnet" "sn_priv_az1c_vpc20" {
    vpc_id                  = aws_vpc.vpc20.id
    availability_zone       = "us-east-1c"
    cidr_block              = var.sub_priv_az1c_vpc20_cidr
    map_public_ip_on_launch = false
}

//NATGATEWAY

resource "aws_eip" "eip10" {}

resource "aws_eip" "eip20" {}

resource "aws_nat_gateway" "ngw10" {
 allocation_id = aws_eip.eip10.id
 subnet_id = aws_subnet.sn_pub_az1a_vpc10.id
}

resource "aws_nat_gateway" "ngw20" {
 allocation_id = aws_eip.eip20.id
 subnet_id = aws_subnet.sn_pub_az1a_vpc20.id
}

//ROUTE TABLE

resource "aws_route_table" "rt_sn_pub_az1a_vpc10" {
    vpc_id = aws_vpc.vpc10.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw10.id
    }
    route {
        cidr_block = "20.0.0.0/16"
        gateway_id = aws_vpc_peering_connection.vpc_peering.id
    }

}

resource "aws_route_table" "rt_sn_pub_az1a_vpc20" {
    vpc_id = aws_vpc.vpc20.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw20.id
    }
    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = aws_vpc_peering_connection.vpc_peering.id
    }

}

resource "aws_route_table" "rt_sn_priv_az1c_vpc10" {
    vpc_id = aws_vpc.vpc10.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.ngw10.id
    }
    route {
        cidr_block = "20.0.0.0/16"
        gateway_id = aws_vpc_peering_connection.vpc_peering.id
    }
}

resource "aws_route_table" "rt_sn_priv_az1c_vpc20" {
    vpc_id = aws_vpc.vpc20.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.ngw20.id
    }
    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = aws_vpc_peering_connection.vpc_peering.id
    }
}

//ASSOCIATE ROUTE TABLE

resource "aws_route_table_association" "rta_sn_pub_az1a_vpc10" {
    subnet_id      = aws_subnet.sn_pub_az1a_vpc10.id
    route_table_id = aws_route_table.rt_sn_pub_az1a_vpc10.id
}

resource "aws_route_table_association" "rta_sn_pub_az1a_vpc20" {
    subnet_id      = aws_subnet.sn_pub_az1a_vpc20.id
    route_table_id = aws_route_table.rt_sn_pub_az1a_vpc20.id
}

resource "aws_route_table_association" "rta_sn_priv_az1c_vpc10" {
    subnet_id         = aws_subnet.sn_priv_az1c_vpc10.id
    route_table_id    = aws_route_table.rt_sn_priv_az1c_vpc10.id   
}

resource "aws_route_table_association" "rta_sn_priv_az1c_vpc20" {
    subnet_id         = aws_subnet.sn_priv_az1c_vpc20.id
    route_table_id    = aws_route_table.rt_sn_priv_az1c_vpc20.id
}