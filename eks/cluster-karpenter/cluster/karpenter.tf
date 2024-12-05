module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.31.0"

  cluster_name = module.eks.cluster_name
  namespace    = "karpenter"

  enable_pod_identity             = false
  create_pod_identity_association = false

  enable_irsa            = true
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  create_node_iam_role    = true
  create_instance_profile = true

  node_iam_role_name = "${module.eks.cluster_name}-node"
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  iam_role_tags      = merge(local.karpenter_discovery_tag, var.tags)
  node_iam_role_tags = merge(local.karpenter_discovery_tag, var.tags)
  tags               = merge(local.karpenter_discovery_tag, var.tags)
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  chart               = "karpenter"
  repository_username = var.ecr_token.user_name
  repository_password = var.ecr_token.password
  version             = var.helm_chart_versions.karpenter
  wait                = false


  dynamic "set" {
    for_each = {
      "settings.clusterName"                                      = module.eks.cluster_name
      "settings.clusterEndpoint"                                  = module.eks.cluster_endpoint
      "settings.interruptionQueue"                                = module.karpenter.queue_name
      "serviceAccount.create"                                     = "true"
      "serviceAccount.name"                                       = module.karpenter.service_account
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.karpenter.iam_role_arn
      "replicas"                                                  = 1
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }

  depends_on = [module.eks]
}
