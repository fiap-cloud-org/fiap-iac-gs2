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
  agent_user_data = file("${path.module}/scripts/nagios-agent.sh")
}

# Servidor Nagios Core (VPC principal, subnet pública)

resource "aws_instance" "nagios_core" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  subnet_id                   = var.primary_public_subnet_id
  vpc_security_group_ids      = [aws_security_group.primary_public.id]
  key_name                    = "vockey"
  user_data                   = local.nagios_core_user_data
  user_data_replace_on_change = true
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

  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [each.value.security_group_id]
  key_name                    = "vockey"
  user_data                   = local.agent_user_data
  user_data_replace_on_change = true
  tags = {
    Name = each.key
  }
}
