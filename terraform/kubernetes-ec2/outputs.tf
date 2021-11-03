output "k8s_cluster_name" {
  description = "Kubernetes cluster name"
  value       = var.cluster_name
}

output "master_public_dns" {
  description = "Master node's public dns"
  value       = module.ec2.master_public_dns
}
output "worker_public_dns" {
  description = "Worker node's public dns"
  value       = module.ec2.worker_public_dns
}
