locals {
  name   = "choshsh-eks-cluster"
  region = "us-east-1"
  eks_discovery_tag = {
    "eks:discovery:${local.name}" = 1
  }
}

module "eks" {
  source = "./cluster"

  cluster_name    = local.name
  cluster_version = "1.31"

  vpc_id = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.intra_subnets # 컨트롤 플레인 서브넷
  subnet_ids = module.vpc.private_subnets # 워커 노드 서브넷

  eks_discovery_tag = local.eks_discovery_tag

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
    # aws-ebs-csi-driver = {
    #   addon_version        = "v1.35.0-eksbuild.1"
    #   configuration_values = ""
    # }
  }

  tags = {}

  depends_on = [
    module.vpc
  ]
}

output "test" {
  value = {
    control_plane_security_group_id = module.eks.control_plane_security_group_id
    cluster_security_group_id       = module.eks.cluster_security_group_id
    node_group_security_group_id    = module.eks.node_group_security_group_id
  }
}

variable "init" {
  type    = bool
  default = false
}

module "karpenter" {
  source = "./karpenter"

  count = var.init ? 0 : 1

  azs                 = module.vpc.azs
  karpenter_role_name = module.eks.karpenter_role_name
  eks_discovery_tag   = module.eks.eks_discovery_tag
}

module "helm" {
  source = "./helm"

  count = var.init ? 0 : 1
}