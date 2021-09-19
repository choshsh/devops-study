locals {
  profiles = [
    {
      name      = "default",
      namespace = "default",
      labels = {
        compute-type = "fargate"
      }
    },
    {
      name      = "dev",
      namespace = "dev",
      labels = {
        compute-type = "fargate"
      }
    },
    {
      name      = "kube-dns",
      namespace = "kube-system",
      labels = {
        k8s-app = "kube-dns"
      }
    },
    {
      name      = "argocd",
      namespace = "argocd",
      labels    = {}
    },
  ]
}

resource "aws_eks_fargate_profile" "fargate-profiles" {
  cluster_name           = aws_eks_cluster.my-eks-cluster.name
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = var.private_subnet_ids

  for_each             = { for profile in local.profiles : profile.name => profile }
  fargate_profile_name = "${each.value.name}-profile"
  selector {
    namespace = each.value.namespace
    labels    = each.value.labels
  }

  depends_on = [aws_eks_cluster.my-eks-cluster]
}
