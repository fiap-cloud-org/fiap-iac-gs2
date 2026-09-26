variable "primary_vpc_cidr" {
  description = "CIDR da VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  description = "CIDR da VPC secundária (faixa privada RFC 1918, sem sobrepor a principal)"
  type        = string
  default     = "10.20.0.0/16"
}

variable "primary_public_subnet_cidr" {
  description = "CIDR da subnet pública da VPC principal"
  type        = string
  default     = "10.0.1.0/24"
}

variable "primary_private_subnet_cidr" {
  description = "CIDR da subnet privada da VPC principal"
  type        = string
  default     = "10.0.2.0/24"
}

variable "secondary_public_subnet_cidr" {
  description = "CIDR da subnet pública da VPC secundária"
  type        = string
  default     = "10.20.1.0/24"
}

variable "secondary_private_subnet_cidr" {
  description = "CIDR da subnet privada da VPC secundária"
  type        = string
  default     = "10.20.2.0/24"
}

variable "nagios_admin_password" {
  description = "Senha do usuário nagiosadmin na interface web do Nagios"
  type        = string
  sensitive   = true
}
