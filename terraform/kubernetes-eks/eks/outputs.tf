output "endpoint" {
  description = "EKS Cluster endpoint"
  value       = aws_eks_cluster.my-eks-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  description = "EKS Cert"
  value       = aws_eks_cluster.my-eks-cluster.certificate_authority[0].data
}

output "eks_cluster_id" {
  description = "EKS Cluster ID"
  value       = aws_eks_cluster.my-eks-cluster.id
}

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.my-eks-cluster.name
}
