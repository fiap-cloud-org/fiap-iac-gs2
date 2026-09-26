variable "vpc10_id" {}
variable "vpc20_id" {}
variable "vpc10_batata" {}  
variable "vpc20_frita" {}
variable "vpc10_sn_pub_az1a_id" {}
variable "vpc10_sn_priv_az1c_id" {}
variable "vpc20_sn_pub_az1a_id" {}
variable "vpc20_sn_priv_az1c_id" {}
variable "nagios_admin_password" {
  sensitive = true
}
