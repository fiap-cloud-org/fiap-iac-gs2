# Testes offline com provider simulado (mock_provider): nada é criado na AWS
# e nenhuma credencial é necessária. Rode com: terraform init -backend=false && terraform test

mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = {
      id = "ami-0123456789abcdef0"
    }
  }

  # O provider valida o formato dos ARNs, então o mock precisa devolver ARNs válidos.
  mock_resource "aws_lb" {
    defaults = {
      arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/teste/0123456789abcdef"
      dns_name = "teste-alb-123456789.us-east-1.elb.amazonaws.com"
    }
  }

  mock_resource "aws_lb_target_group" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/teste/0123456789abcdef"
    }
  }
}

variables {
  nagios_admin_password = "senha-de-teste-forte"
  snmp_community        = "community-de-teste"
  allowed_ssh_cidrs     = ["203.0.113.10/32"]
}

run "rede_usa_faixas_privadas_e_rotas_do_peering" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    name_prefix                   = "teste"
    primary_vpc_cidr              = "10.0.0.0/16"
    secondary_vpc_cidr            = "10.20.0.0/16"
    primary_public_subnet_cidr    = "10.0.1.0/24"
    primary_public_subnet_b_cidr  = "10.0.3.0/24"
    primary_private_subnet_cidr   = "10.0.2.0/24"
    secondary_public_subnet_cidr  = "10.20.1.0/24"
    secondary_private_subnet_cidr = "10.20.2.0/24"
    availability_zones            = ["us-east-1a", "us-east-1c"]
  }

  assert {
    condition     = contains([for r in aws_route_table.primary_private.route : r.cidr_block], "10.20.0.0/16")
    error_message = "A subnet privada da VPC principal precisa de rota para a VPC secundária pelo peering."
  }

  assert {
    condition     = contains([for r in aws_route_table.secondary_public.route : r.cidr_block], "10.0.0.0/16")
    error_message = "A subnet pública da VPC secundária precisa de rota para a VPC principal pelo peering."
  }

  assert {
    condition     = aws_subnet.primary_public.availability_zone != aws_subnet.primary_public_b.availability_zone
    error_message = "As duas subnets públicas do ALB precisam ficar em zonas diferentes."
  }
}

run "compute_cria_core_e_sete_agentes_com_user_data_parametrizado" {
  command = plan

  module {
    source = "./modules/compute"
  }

  variables {
    name_prefix                 = "teste"
    primary_vpc_id              = "vpc-primary"
    secondary_vpc_id            = "vpc-secondary"
    primary_vpc_cidr            = "10.0.0.0/16"
    secondary_vpc_cidr          = "10.20.0.0/16"
    primary_public_subnet_id    = "subnet-primary-public"
    primary_private_subnet_id   = "subnet-primary-private"
    secondary_public_subnet_id  = "subnet-secondary-public"
    secondary_private_subnet_id = "subnet-secondary-private"
    instance_type               = "t2.micro"
    key_name                    = "vockey"
  }

  assert {
    condition     = length(aws_instance.agent) == 7
    error_message = "Devem existir 7 agentes."
  }

  assert {
    condition     = aws_instance.nagios_core.subnet_id == "subnet-primary-public"
    error_message = "O Nagios Core fica na subnet pública da VPC principal."
  }

  assert {
    condition     = strcontains(aws_instance.nagios_core.user_data, "nagiosadmin \"senha-de-teste-forte\"")
    error_message = "O user-data do Nagios Core precisa usar a senha da variável."
  }

  assert {
    condition     = !strcontains(aws_instance.nagios_core.user_data, "nagiosadmin nagiosadmin")
    error_message = "A senha padrão nagiosadmin não pode aparecer no user-data."
  }

  assert {
    condition     = strcontains(aws_instance.agent["agent-secondary-private-1"].user_data, "rocommunity community-de-teste 10.0.0.0/16")
    error_message = "O SNMP dos agentes deve usar a community da variável e aceitar só a VPC do Nagios."
  }

  assert {
    condition     = [for r in aws_security_group.primary_public.ingress : tolist(r.cidr_blocks) if r.from_port == 22] == [tolist(["203.0.113.10/32"])]
    error_message = "O SSH deve aceitar só as faixas de allowed_ssh_cidrs."
  }
}

run "senha_curta_e_recusada" {
  command = plan

  variables {
    nagios_admin_password = "curta"
  }

  expect_failures = [var.nagios_admin_password]
}

run "stack_completa_com_alb" {
  command = apply

  assert {
    condition     = length(output.agent_private_ips) == 7
    error_message = "A saída agent_private_ips deve listar os 7 agentes."
  }

  assert {
    condition     = output.nagios_url == "http://teste-alb-123456789.us-east-1.elb.amazonaws.com/nagios"
    error_message = "nagios_url deve apontar para /nagios no DNS do ALB."
  }
}
