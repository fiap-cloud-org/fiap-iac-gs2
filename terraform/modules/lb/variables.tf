variable "name_prefix" {
  description = "Prefixo dos nomes e da tag Name"
  type        = string
}

variable "vpc_id" {
  description = "VPC do load balancer e do target group"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC (destino liberado na saída do ALB)"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets públicas do ALB, em pelo menos duas zonas"
  type        = list(string)
}

variable "target_instance_ids" {
  description = "Instâncias registradas no target group, por nome"
  type        = map(string)
}
