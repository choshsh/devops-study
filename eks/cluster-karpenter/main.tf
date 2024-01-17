locals {
  name              = "choshsh-eks-cluster"
  region            = "ap-northeast-2"
  eks_discovery_tag = {
    "eks:discovery:${local.name}" = 1
  }
}

module "eks" {
  source = "./cluster"

  cluster_name    = "choshsh-eks-cluster"
  cluster_version = "1.28"

  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.intra_subnets # 컨트롤 플레인 서브넷
  subnet_ids               = module.vpc.private_subnets # 워커 노드 서브넷

  eks_discovery_tag = local.eks_discovery_tag

  cluster_addons = {
    kube-proxy = {
      addon_version        = "v1.28.2-eksbuild.2"
      configuration_values = ""
    }
    vpc-cni = {
      addon_version        = "v1.15.4-eksbuild.1"
      configuration_values = ""
    }
    coredns = {
      addon_version        = "v1.10.1-eksbuild.6"
      configuration_values = jsonencode({
        computeType  = "Fargate"
        replicaCount = 1
        resources    = {
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
    #    aws-ebs-csi-driver = {
    #      addon_version = "v1.25.0-eksbuild.1"
    #      configuration_values= jsonencode({
    #        node = {
    #          affinity = {
    #            nodeAffinity = {
    #              requiredDuringSchedulingIgnoredDuringExecution = {
    #                nodeSelectorTerms = [
    #                  {
    #                    matchExpressions = [
    #                      {
    #                        key      = "eks.amazonaws.com/nodegroup"
    #                        operator = "In"
    #                        values   = ["ng-1"]
    #                      }
    #                    ]
    #                  }
    #                ]
    #              }
    #            }
    #          }
    #        }
    #      })
    #    }
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