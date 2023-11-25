locals {
  name   = "choshsh-eks-cluster"
  region = "us-east-1"

}


module "eks" {
  source = "./cluster"

  cluster_name    = "choshsh-eks-cluster"
  cluster_version = "1.27"

  vpc_id                   = module.vpc.vpc_id
  azs                      = local.azs
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_addons = {
    kube-proxy = {
      addon_version        = "v1.27.6-eksbuild.2"
      configuration_values = ""
    }
    vpc-cni = {
      addon_version = "v1.15.1-eksbuild.1"
      configuration_values = jsonencode({
        env = {
          WARM_IP_TARGET = "4"
        }
      })
    }
    coredns = {
      addon_version = "v1.10.1-eksbuild.6"
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



  tags = {}
}
