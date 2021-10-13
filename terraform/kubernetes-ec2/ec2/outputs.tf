output "master_public_dns" {
  description = "Master node's public dns"
  value       = [for s in aws_instance.master : s.public_dns]
}
output "worker_public_dns" {
  description = "Master node's public dns"
  value       = [for s in aws_instance.worker : s.public_dns]
}
