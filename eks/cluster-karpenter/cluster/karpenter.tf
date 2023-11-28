module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.20.0"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  # Node IAM role
  enable_karpenter_instance_profile_creation = true

  iam_role_name            = "${var.cluster_name}-node"
  iam_role_use_name_prefix = false
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # IRSA IAM role
  irsa_name            = "${var.cluster_name}-irsa"
  irsa_use_name_prefix = false

  # Discovery tags
  irsa_tag_key    = keys(local.eks_discovery_tag)[0]
  irsa_tag_values = [values(local.eks_discovery_tag)[0]]

  tags = var.tags
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  #  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  #  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart   = "karpenter"
  version = "v0.32.2"

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "settings.interruptionQueueName"
    value = module.karpenter.queue_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "replica"
    value = 1
  }

  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }

  timeout = 60 * 20 # 20 minutes
}
