module "network" {
  source                   = "./modules/network"
  vpc10_feijao             = var.vpc10_peixao
  vpc20_sazon              = var.vpc20_pipoca
  sub_pub_az1a_vpc10_cidr  = var.sub_pub_az1a_vpc10_cidr
  sub_pub_az1a_vpc20_cidr  = var.sub_pub_az1a_vpc20_cidr
  sub_priv_az1c_vpc10_cidr = var.sub_priv_az1c_vpc10_cidr
  sub_priv_az1c_vpc20_cidr = var.sub_priv_az1c_vpc20_cidr
}



module "compute" {
  source                = "./modules/compute"
  vpc10_id              = module.network.vpc10_id
  vpc20_id              = module.network.vpc20_id
  vpc10_batata          = var.vpc10_peixao
  vpc20_frita           = var.vpc20_pipoca
  vpc10_sn_pub_az1a_id  = module.network.sn_pub_az1a_vpc10_id
  vpc10_sn_priv_az1c_id = module.network.sn_priv_az1c_vpc10_id
  vpc20_sn_pub_az1a_id  = module.network.sn_pub_az1a_vpc20_id
  vpc20_sn_priv_az1c_id = module.network.sn_priv_az1c_vpc20_id
  nagios_admin_password = var.nagios_admin_password
}

module "lb" {
  source         = "./modules/lb"
  vpc10_id       = module.network.vpc10_id
  nagios-core_id = module.compute.nagios-core_id
  node_c_id      = module.compute.node_c_id
  node_a_id      = module.compute.node_a_id
  node_d_id      = module.compute.node_d_id
  node_b_id      = module.compute.node_b_id
  node_wim_id    = module.compute.node_wim_id
  node_e_id      = module.compute.node_e_id
  node_f_id      = module.compute.node_f_id
  vpc20_id       = module.network.vpc20_id
}