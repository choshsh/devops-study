output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = var.eks_enable > 0 ? module.eks[0].endpoint : null
}

output "eks_name" {
  description = "EKS Cluster Name"
  value       = var.eks_enable > 0 ? module.eks[0].eks_cluster_name : null
}

# output "bestion_endpoint" {
#   description = "Bestion Endpoint"
#   value       = var.eks_enable < 1 ? module.ec2-k8s[0].bestion_endpoint : null
# }
