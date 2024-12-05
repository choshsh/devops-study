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
      "global.instanceProfileName"                         = module.eks.karpenter_instance_profile_name
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
