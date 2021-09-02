output "ec2_id" {
  description = "EC2 ID"
  value       = aws_instance.example.id
}

output "ec2_private_ip" {
  description = "EC2 ID"
  value       = aws_instance.example.private_ip
}
