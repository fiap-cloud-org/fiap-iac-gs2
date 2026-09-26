output "nagios_core_instance_id" {
  value = aws_instance.nagios_core.id
}

output "nagios_core_public_ip" {
  value = aws_instance.nagios_core.public_ip
}

output "agent_instance_ids" {
  description = "IDs das instâncias dos agentes, por nome"
  value       = { for name, instance in aws_instance.agent : name => instance.id }
}

output "agent_private_ips" {
  description = "IPs privados dos agentes, por nome (usados para cadastrar os hosts no Nagios)"
  value       = { for name, instance in aws_instance.agent : name => instance.private_ip }
}
