output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
output "subnet_ids" {
  description = "Subnet IDs"
  value       = module.vpc.subnet_ids
}
# output "eks_endpoint" {
#   value = module.eks.endpoint
# }
# output "kubeconfig-certificate-authority-data" {
#   value = module.eks.kubeconfig-certificate-authority-data
# }
# output "eks_id" {
#   value = module.eks.eks_cluster_id
# }
