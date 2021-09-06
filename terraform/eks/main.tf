locals {
  tags = {
    Type = "eks"
  }
}

# EKS 생성 시 하고싶은 이름이 자꾸 중복된다고 나와서 뒤에 랜덤 UUID 붙임
resource "random_uuid" "eks" {}

# EKS 클러스터
resource "aws_eks_cluster" "my-eks-cluster" {
  name     = "${var.workspace}-eks-clustertest-${random_uuid.eks.result}"
  role_arn = aws_iam_role.cluster-service-role.arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = merge(local.tags, {
    Name = "${var.workspace}-eks-cluster"
  })
  depends_on = [aws_iam_role_policy_attachment.my-AmazonEKSClusterPolicy]
}

# EKS 노드 그룹 : Ingress 또는 stateful한 pod 배포용
resource "aws_eks_node_group" "my-eks-node-group" {
  cluster_name    = aws_eks_cluster.my-eks-cluster.name
  node_group_name = "example"
  node_role_arn   = aws_iam_role.node-group.arn
  subnet_ids      = var.private_subnet_ids
  labels = {
    "node/role" = "ingress"
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(local.tags, {
    Name = "${var.workspace}-eks-node-group"
  })
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}
