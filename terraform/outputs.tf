output "nagios_core_public_ip" {
  description = "IP público do servidor Nagios Core"
  value       = module.compute.nagios_core_public_ip
}

output "nagios_url" {
  description = "Interface web do Nagios"
  value       = "http://${module.compute.nagios_core_public_ip}/nagios"
}

output "agent_private_ips" {
  description = "IPs privados dos agentes, por nome"
  value       = module.compute.agent_private_ips
}
