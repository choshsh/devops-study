output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.my-vpc.id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "linux_sg_id" {
  description = "Defualt Custom Security Group ID"
  value       = aws_security_group.linux-default.id
}

output "allow_tls_sg_id" {
  description = "In VPC Security Group ID"
  value       = aws_security_group.allow_tls.id
}
