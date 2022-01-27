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
  enabled_cluster_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

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
  node_group_name = var.eks_node_group.name
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.eks_node_group.instance_type]
  ami_type        = var.eks_node_group.ami_type

  labels = {
    "compute-type" = "ec2"
  }

  scaling_config {
    desired_size = var.eks_node_group.desired_size
    max_size     = var.eks_node_group.max_size
    min_size     = var.eks_node_group.min_size
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
