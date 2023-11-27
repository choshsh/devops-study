locals {
  name   = "choshsh-eks-cluster"
  region = "us-east-1"
}


module "eks" {
  source = "./cluster"

  cluster_name    = "choshsh-eks-cluster"
  cluster_version = "1.28"

  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.intra_subnets # 컨트롤 플레인 서브넷
  subnet_ids               = module.vpc.private_subnets # 워커 노드 서브넷

  cluster_addons = {
    kube-proxy = {
      addon_version        = "v1.28.2-eksbuild.2"
      configuration_values = ""
    }
    vpc-cni = {
      addon_version        = "v1.15.4-eksbuild.1"
      configuration_values = jsonencode({
        env = {
          WARM_IP_TARGET = "4"
        }
      })
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
}

module "karpenter" {
  source = "./karpenter"

  azs                 = module.vpc.azs
  eks_cluster_name    = module.eks.cluster_name
  karpenter_role_name = module.eks.karpenter_role_name
}