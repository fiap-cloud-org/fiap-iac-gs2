variable "vpc_id" {
  description = "VPC do target group"
  type        = string
}

variable "target_instance_ids" {
  description = "Instâncias registradas no target group, por nome"
  type        = map(string)
}
