# Security groups: tráfego livre entre as duas VPCs; as subnets públicas
# também aceitam SSH (22) e HTTP (80) da internet.

resource "aws_security_group" "primary_public" {
  vpc_id = var.primary_vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.primary_vpc_cidr, var.secondary_vpc_cidr]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "secondary_public" {
  vpc_id = var.secondary_vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.primary_vpc_cidr, var.secondary_vpc_cidr]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "primary_private" {
  vpc_id = var.primary_vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.primary_vpc_cidr, var.secondary_vpc_cidr]
  }
}

resource "aws_security_group" "secondary_private" {
  vpc_id = var.secondary_vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.primary_vpc_cidr, var.secondary_vpc_cidr]
  }
}

# User-data

data "template_file" "nagios_core_user_data" {
  template = file("./modules/compute/scripts/nagios-core.sh")
  vars = {
    nagios_admin_password = var.nagios_admin_password
  }
}

data "template_file" "agent_user_data" {
  template = file("./modules/compute/scripts/nagios-agent.sh")
}

# Servidor Nagios Core (VPC principal, subnet pública)

resource "aws_instance" "nagios_core" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = var.primary_public_subnet_id
  vpc_security_group_ids = [aws_security_group.primary_public.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios_core_user_data.rendered)
  tags = {
    Name = "nagios-core"
  }
}

# Agentes monitorados (NCPA + SNMP): um mapa nome => subnet/security group

locals {
  agents = {
    "agent-primary-public"      = { subnet_id = var.primary_public_subnet_id, security_group_id = aws_security_group.primary_public.id }
    "agent-primary-private-1"   = { subnet_id = var.primary_private_subnet_id, security_group_id = aws_security_group.primary_private.id }
    "agent-primary-private-2"   = { subnet_id = var.primary_private_subnet_id, security_group_id = aws_security_group.primary_private.id }
    "agent-secondary-public-1"  = { subnet_id = var.secondary_public_subnet_id, security_group_id = aws_security_group.secondary_public.id }
    "agent-secondary-public-2"  = { subnet_id = var.secondary_public_subnet_id, security_group_id = aws_security_group.secondary_public.id }
    "agent-secondary-private-1" = { subnet_id = var.secondary_private_subnet_id, security_group_id = aws_security_group.secondary_private.id }
    "agent-secondary-private-2" = { subnet_id = var.secondary_private_subnet_id, security_group_id = aws_security_group.secondary_private.id }
  }
}

resource "aws_instance" "agent" {
  for_each = local.agents

  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [each.value.security_group_id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.agent_user_data.rendered)
  tags = {
    Name = each.key
  }
}
