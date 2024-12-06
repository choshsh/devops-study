module "eks" {
  source = "./cluster"

  cluster_name      = local.name
  cluster_version   = "1.31"
  region            = local.region
  eks_discovery_tag = local.eks_discovery_tag

  # 네트워크
  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.intra_subnets   # 컨트롤 플레인 서브넷
  subnet_ids               = module.vpc.private_subnets # 워커 노드 서브넷

  ecr_token = data.aws_ecrpublic_authorization_token.token

  cluster_addons = {
    kube-proxy = {
      addon_version        = "v1.31.2-eksbuild.3"
      configuration_values = ""
    }
    vpc-cni = {
      addon_version        = "v1.19.0-eksbuild.1"
      configuration_values = ""
    }
    coredns = {
      addon_version = "v1.11.3-eksbuild.2"
      configuration_values = jsonencode({
        computeType  = "Fargate"
        replicaCount = 1
        resources = {
          limits = {
            cpu    = "0.25"
            memory = "256M"
          }
          requests = {
            cpu    = "0.25"
            memory = "256M"
          }
        }
      })
    }
  }

  tags = {
    Name = local.name
  }

  depends_on = [
    module.vpc
  ]
}

resource "helm_release" "karpenter_resources" {
  name        = "karpenter-resources"
  namespace   = "karpenter"
  chart       = "./karpenter-resources"
  max_history = 3

  values = [
    file("./karpenter-resources/values-${var.env}.yaml")
  ]

  dynamic "set" {
    for_each = {
      "global.env"                                         = var.env
      "global.instanceProfile"                             = module.eks.karpenter_instance_profile_name
      "global.eksDiscoveryTag.eks:discovery:${local.name}" = module.eks.eks_discovery_tag["eks:discovery:${local.name}"]
      "global.tags.Env"                                    = var.env
      "global.tags.Service"                                = "eks"
      "global.tags.Team"                                   = "sre"
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [module.eks]
}

resource "helm_release" "metrics_server" {
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  name       = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.2"

  depends_on = [module.eks]
}

# TODO: kubectl 로 설치하고 있는데 개선 필요
# kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml

locals {
  istio = {
    namespace = "istio-system"
    repo      = "https://istio-release.storage.googleapis.com/charts"
    version   = "1.24.1"
    revision  = "1-24"
  }
  max_history = 5
}

resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = local.istio.namespace
  }

  depends_on = [module.eks]
}

resource "helm_release" "istio_base" {
  repository  = "https://istio-release.storage.googleapis.com/charts"
  chart       = "base"
  name        = "istio-base"
  version     = local.istio.version
  namespace   = local.istio.namespace
  max_history = local.max_history

  dynamic "set" {
    for_each = {
      "defaultRevision" = local.istio.revision
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [kubernetes_namespace.istio-system]
}

resource "helm_release" "istiod" {
  repository  = local.istio.repo
  chart       = "istiod"
  name        = "istiod"
  version     = local.istio.version
  namespace   = local.istio.namespace
  max_history = local.max_history

  values = [
    file("${path.module}/values/istiod.yaml")
  ]

  dynamic "set" {
    for_each = {
      "revision" = local.istio.revision
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_cni" {
  repository  = local.istio.repo
  chart       = "cni"
  name        = "istio-cni"
  version     = local.istio.version
  namespace   = local.istio.namespace
  max_history = local.max_history

  values = [
    file("${path.module}/values/affinity.yaml")
  ]

  dynamic "set" {
    for_each = {
      "profile"  = "ambient"
      "revision" = local.istio.revision
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [helm_release.istiod]
}

resource "helm_release" "ztunnel" {
  repository  = local.istio.repo
  chart       = "ztunnel"
  name        = "ztunnel"
  version     = local.istio.version
  namespace   = local.istio.namespace
  max_history = local.max_history

  values = [
    file("${path.module}/values/affinity.yaml")
  ]

  dynamic "set" {
    for_each = {
      "revision" = local.istio.revision
    }
    content {
      name  = set.key
      value = set.value
    }
  }
  depends_on = [helm_release.istio_cni]
}

resource "helm_release" "ingress_alb" {
  repository  = local.istio.repo
  chart       = "gateway"
  name        = "istio-ingress-alb"
  version     = local.istio.version
  namespace   = local.istio.namespace
  max_history = local.max_history

  values = [
    file("${path.module}/values/istio_ingress_base.yaml")
  ]

  dynamic "set" {
    for_each = {
      "revision"     = local.istio.revision
      "service.type" = "ClusterIP"
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [helm_release.istiod]
}

resource "helm_release" "ingress_nlb" {
  repository  = local.istio.repo
  chart       = "gateway"
  name        = "istio-ingress-nlb"
  version     = local.istio.version
  namespace   = local.istio.namespace
  max_history = local.max_history

  values = [
    templatefile("${path.module}/values/istio_ingress_nlb.yaml", {
      "name"    = "eks-test-v2-nlb"
      "acm_arn" = "arn:aws:acm:us-east-1:801167518143:certificate/5f0f8f42-8bff-45e8-9fb1-6b59323d2217"
    }),
    file("${path.module}/values/istio_ingress_base.yaml")
  ]

  dynamic "set" {
    for_each = {
      "revision" = local.istio.revision
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [helm_release.istiod]
}