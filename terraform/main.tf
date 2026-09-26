# Orquestrador: liga os módulos network, compute e lb.

module "network" {
  source                        = "./modules/network"
  name_prefix                   = var.project_name
  primary_vpc_cidr              = var.primary_vpc_cidr
  secondary_vpc_cidr            = var.secondary_vpc_cidr
  primary_public_subnet_cidr    = var.primary_public_subnet_cidr
  primary_public_subnet_b_cidr  = var.primary_public_subnet_b_cidr
  primary_private_subnet_cidr   = var.primary_private_subnet_cidr
  secondary_public_subnet_cidr  = var.secondary_public_subnet_cidr
  secondary_private_subnet_cidr = var.secondary_private_subnet_cidr
  availability_zones            = var.availability_zones
}

module "compute" {
  source                      = "./modules/compute"
  name_prefix                 = var.project_name
  primary_vpc_id              = module.network.primary_vpc_id
  secondary_vpc_id            = module.network.secondary_vpc_id
  primary_vpc_cidr            = var.primary_vpc_cidr
  secondary_vpc_cidr          = var.secondary_vpc_cidr
  primary_public_subnet_id    = module.network.primary_public_subnet_id
  primary_private_subnet_id   = module.network.primary_private_subnet_id
  secondary_public_subnet_id  = module.network.secondary_public_subnet_id
  secondary_private_subnet_id = module.network.secondary_private_subnet_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  nagios_admin_password       = var.nagios_admin_password
  snmp_community              = var.snmp_community
  allowed_ssh_cidrs           = var.allowed_ssh_cidrs
}

module "lb" {
  source      = "./modules/lb"
  name_prefix = var.project_name
  vpc_id      = module.network.primary_vpc_id
  vpc_cidr    = var.primary_vpc_cidr
  subnet_ids  = module.network.primary_public_subnet_ids
  target_instance_ids = {
    "nagios-core"          = module.compute.nagios_core_instance_id
    "agent-primary-public" = module.compute.agent_instance_ids["agent-primary-public"]
  }
}
