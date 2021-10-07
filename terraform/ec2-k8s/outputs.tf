output "bestion_endpoint" {
  description = "bestion_endpoint"
  value       = aws_instance.bestion.public_dns
}
