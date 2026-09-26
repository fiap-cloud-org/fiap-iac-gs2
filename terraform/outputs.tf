output "nagios_core_public_ip" {
  description = "IP público do servidor Nagios Core"
  value       = module.compute.nagios_core_public_ip
}

output "alb_dns_name" {
  description = "DNS público do Application Load Balancer"
  value       = module.lb.alb_dns_name
}

output "nagios_url" {
  description = "Interface web do Nagios pelo ALB (usuário nagiosadmin)"
  value       = "http://${module.lb.alb_dns_name}/nagios"
}

output "nagios_direct_url" {
  description = "Interface web do Nagios direto na instância"
  value       = "http://${module.compute.nagios_core_public_ip}/nagios"
}

output "agent_private_ips" {
  description = "IPs privados dos agentes, por nome"
  value       = module.compute.agent_private_ips
}
