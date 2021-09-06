output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.endpoint
}

output "eks_name" {
  description = "EKS Cluster Name"
  value       = module.eks.eks_cluster_name
}
