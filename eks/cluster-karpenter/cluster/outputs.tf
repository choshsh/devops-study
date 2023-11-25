# EKS 클러스터의 이름
output "cluster_name" {
  value = module.eks.cluster_name
}

# EKS 클러스터의 API Endpoint
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# EKS 클러스터의 API Server의 CA 인증서
output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

