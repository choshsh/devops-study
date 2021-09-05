output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.my-vpc.id
}
output "subnet_ids" {
  description = "Defualt Route Table ID"
  value       = [for s in aws_subnet.private : s.id]
}
output "default_sg_id" {
  description = "Defualt Custom Security Group ID"
  value       = aws_security_group.default-sg.id
}
