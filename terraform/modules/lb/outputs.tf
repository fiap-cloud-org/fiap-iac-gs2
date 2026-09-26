output "alb_dns_name" {
  description = "DNS público do ALB"
  value       = aws_lb.nagios.dns_name
}
