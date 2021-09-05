locals {
  tags = {
    Type = "eks"
  }
}

resource "random_uuid" "eks" {}

resource "aws_eks_cluster" "my-eks-cluster" {
  name     = "${var.workspace}-eks-clustertest-${random_uuid.eks.result}"
  role_arn = aws_iam_role.cluster-service-role.arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }
  tags = merge(local.tags, {
    Name = "${var.workspace}-eks-cluster"
  })
  depends_on = [aws_iam_role_policy_attachment.my-AmazonEKSClusterPolicy]
}


