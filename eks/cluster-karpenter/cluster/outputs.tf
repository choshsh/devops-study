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

# karpenter로 생성되는 NodeGroup의 IAM Role 이름
output "karpenter_role_name" {
  value = module.karpenter.node_iam_role_name
}

output "karpenter_instance_profile_name" {
  value = module.karpenter.instance_profile_name
}

output "control_plane_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "node_group_security_group_id" {
  value = aws_security_group.eks_node.id
}

output "eks_discovery_tag" {
  value = local.karpenter_discovery_tag
}
