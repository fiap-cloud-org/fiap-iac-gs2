variable "project_name" {
  description = "Prefixo dos nomes dos recursos e valor da tag Project"
  type        = string
  default     = "fiap-iac-gs2"
}

variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Duas zonas da região: a primeira recebe as subnets públicas e a segunda as privadas"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1c"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Informe exatamente duas zonas de disponibilidade."
  }
}

variable "instance_type" {
  description = "Tipo das instâncias EC2 (Nagios Core e agentes)"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair da AWS usado no SSH das instâncias (vockey é o padrão do AWS Academy)"
  type        = string
  default     = "vockey"
}

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

  validation {
    condition     = length(var.nagios_admin_password) >= 12
    error_message = "Use uma senha com pelo menos 12 caracteres."
  }
}

variable "snmp_community" {
  description = "Community SNMP (somente leitura) configurada nos agentes"
  type        = string
  sensitive   = true
}

variable "allowed_ssh_cidrs" {
  description = "Faixas que podem acessar as instâncias públicas por SSH (restrinja ao seu IP)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
