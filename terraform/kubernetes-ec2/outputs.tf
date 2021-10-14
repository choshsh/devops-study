output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "master_public_dns" {
  description = "Master node's public dns"
  value       = module.ec2.master_public_dns
}
output "worker_public_dns" {
  description = "Worker node's public dns"
  value       = module.ec2.worker_public_dns
}
