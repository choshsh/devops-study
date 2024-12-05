module "aws_load_balancer_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.48.0"

  role_name                              = format("%s-lb-controller", module.eks.cluster_name)
  attach_load_balancer_controller_policy = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
  depends_on = [
    module.eks
  ]
}

resource "kubernetes_service_account" "aws_load_balancer_service_account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.aws_load_balancer_irsa.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }

  depends_on = [
    module.aws_load_balancer_irsa
  ]
}

resource "helm_release" "aws_load_balancer" {
  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.8.1"
  wait       = false

  dynamic "set" {
    for_each = {
      "region"                = "ap-northeast-2"
      "vpcId"                 = var.vpc_id
      "image.repository"      = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"
      "serviceAccount.create" = "false"
      "serviceAccount.name"   = kubernetes_service_account.aws_load_balancer_service_account.metadata[0].name
      "clusterName"           = module.eks.cluster_name
      "replicaCount"          = 1
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  timeout = 60 * 25 # 25 minutes

  depends_on = [
    kubernetes_service_account.aws_load_balancer_service_account
  ]
}
