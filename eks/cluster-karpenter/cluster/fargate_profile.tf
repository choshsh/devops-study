locals {
  is_fargate_enabled = length(var.fargate_profiles) > 0
}

resource "aws_eks_fargate_profile" "this" {
  for_each = var.fargate_profiles

  cluster_name = module.eks.cluster_name

  selector {
    namespace = each.value.namespace
    labels    = each.value.labels
  }

  fargate_profile_name   = each.key
  pod_execution_role_arn = aws_iam_role.fargate[0].arn
  subnet_ids             = var.subnet_ids
}

data "aws_iam_policy_document" "eks-fargate-pods" {
  count = local.is_fargate_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "fargate" {
  count = local.is_fargate_enabled ? 1 : 0

  name_prefix           = "AmazonEKSFargatePodExecutionRole"
  path                  = "/${var.cluster_name}/"
  assume_role_policy    = data.aws_iam_policy_document.eks-fargate-pods[0].json
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  ]
}