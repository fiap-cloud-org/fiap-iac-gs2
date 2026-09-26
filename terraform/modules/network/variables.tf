variable "name_prefix" {
  description = "Prefixo da tag Name"
  type        = string
}

variable "primary_vpc_cidr" {
  description = "CIDR da VPC principal (Nagios Core e agentes)"
  type        = string
}

variable "secondary_vpc_cidr" {
  description = "CIDR da VPC secundária (agentes monitorados via peering)"
  type        = string
}

variable "primary_public_subnet_cidr" {
  description = "CIDR da subnet pública da VPC principal"
  type        = string
}

variable "primary_private_subnet_cidr" {
  description = "CIDR da subnet privada da VPC principal"
  type        = string
}

variable "secondary_public_subnet_cidr" {
  description = "CIDR da subnet pública da VPC secundária"
  type        = string
}

variable "secondary_private_subnet_cidr" {
  description = "CIDR da subnet privada da VPC secundária"
  type        = string
}

variable "availability_zones" {
  description = "Zonas das subnets: [0] públicas, [1] privadas"
  type        = list(string)
}
