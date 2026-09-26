output "primary_vpc_id" {
  value = aws_vpc.primary.id
}

output "secondary_vpc_id" {
  value = aws_vpc.secondary.id
}

output "primary_public_subnet_id" {
  value = aws_subnet.primary_public.id
}

output "primary_private_subnet_id" {
  value = aws_subnet.primary_private.id
}

output "secondary_public_subnet_id" {
  value = aws_subnet.secondary_public.id
}

output "secondary_private_subnet_id" {
  value = aws_subnet.secondary_private.id
}
