resource "aws_eks_fargate_profile" "fargate-profile" {
  cluster_name           = aws_eks_cluster.my-eks-cluster.name
  fargate_profile_name   = "fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = "example"
    labels = {
      allocation = "fargate"
    }
  }
  depends_on = [aws_eks_cluster.my-eks-cluster]
}

# CoreDNS
resource "aws_eks_fargate_profile" "kube-dns-profile" {
  cluster_name           = aws_eks_cluster.my-eks-cluster.name
  fargate_profile_name   = "kube-dns-profile"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = "kube-system"
  }
  depends_on = [aws_eks_cluster.my-eks-cluster]
}
