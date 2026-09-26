# Security groups: tráfego livre entre as duas VPCs; as subnets públicas
# também aceitam HTTP (80) da internet e SSH (22) das faixas em allowed_ssh_cidrs.

resource "aws_security_group" "primary_public" {
  vpc_id      = var.primary_vpc_id
  name        = "${var.name_prefix}-sg-primary-public"
  description = "Subnet publica da VPC principal"
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
    cidr_blocks = var.allowed_ssh_cidrs
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name_prefix}-sg-primary-public"
  }
}

resource "aws_security_group" "secondary_public" {
  vpc_id      = var.secondary_vpc_id
  name        = "${var.name_prefix}-sg-secondary-public"
  description = "Subnet publica da VPC secundaria"
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
    cidr_blocks = var.allowed_ssh_cidrs
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name_prefix}-sg-secondary-public"
  }
}

resource "aws_security_group" "primary_private" {
  vpc_id      = var.primary_vpc_id
  name        = "${var.name_prefix}-sg-primary-private"
  description = "Subnet privada da VPC principal"
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
  tags = {
    Name = "${var.name_prefix}-sg-primary-private"
  }
}

resource "aws_security_group" "secondary_private" {
  vpc_id      = var.secondary_vpc_id
  name        = "${var.name_prefix}-sg-secondary-private"
  description = "Subnet privada da VPC secundaria"
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
  tags = {
    Name = "${var.name_prefix}-sg-secondary-private"
  }
}

# AMI: Amazon Linux 2 mais recente (os scripts usam yum e amazon-linux-extras).
# Antes era um ID fixo, que deixa de existir quando a AWS publica novas versões.

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User-data: templatefile() substitui o data source template_file, do provider
# hashicorp/template (descontinuado e sem binário para várias plataformas).
# path.module deixa o caminho independente do diretório onde o terraform roda.

locals {
  nagios_core_user_data = templatefile("${path.module}/scripts/nagios-core.sh", {
    nagios_admin_password = var.nagios_admin_password
  })
  agent_user_data = templatefile("${path.module}/scripts/nagios-agent.sh", {
    snmp_community   = var.snmp_community
    snmp_source_cidr = var.primary_vpc_cidr
  })
}

# Servidor Nagios Core (VPC principal, subnet pública)

resource "aws_instance" "nagios_core" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = var.primary_public_subnet_id
  vpc_security_group_ids      = [aws_security_group.primary_public.id]
  key_name                    = var.key_name
  user_data                   = local.nagios_core_user_data
  user_data_replace_on_change = true
  tags = {
    Name = "${var.name_prefix}-nagios-core"
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

  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [each.value.security_group_id]
  key_name                    = var.key_name
  user_data                   = local.agent_user_data
  user_data_replace_on_change = true
  tags = {
    Name = "${var.name_prefix}-${each.key}"
  }
}
