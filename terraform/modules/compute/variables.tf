variable "primary_vpc_id" {
  description = "ID da VPC principal"
  type        = string
}

variable "secondary_vpc_id" {
  description = "ID da VPC secundária"
  type        = string
}

variable "primary_vpc_cidr" {
  description = "CIDR da VPC principal (liberado entre as VPCs)"
  type        = string
}

variable "secondary_vpc_cidr" {
  description = "CIDR da VPC secundária (liberado entre as VPCs)"
  type        = string
}

variable "primary_public_subnet_id" {
  description = "Subnet pública da VPC principal"
  type        = string
}

variable "primary_private_subnet_id" {
  description = "Subnet privada da VPC principal"
  type        = string
}

variable "secondary_public_subnet_id" {
  description = "Subnet pública da VPC secundária"
  type        = string
}

variable "secondary_private_subnet_id" {
  description = "Subnet privada da VPC secundária"
  type        = string
}

variable "nagios_admin_password" {
  description = "Senha do usuário nagiosadmin na interface web do Nagios"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Tipo das instâncias EC2"
  type        = string
}

variable "key_name" {
  description = "Key pair usado no SSH das instâncias"
  type        = string
}
