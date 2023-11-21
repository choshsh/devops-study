data "aws_availability_zones" "available" {}
data "aws_ecrpublic_authorization_token" "token" { provider = aws.virginia }

locals {
  name            = "choshsh-eks-cluster"
  cluster_version = "1.27"
  region          = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Resource   = local.name
    GithubRepo = "devops-study"
    GithubOrg  = "choshsh"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.20.0"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    kube-proxy = {
      addon_version = "v1.27.6-eksbuild.2"
    }
    vpc-cni = {
      addon_version        = "v1.15.1-eksbuild.1"
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
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = true
  create_node_security_group    = true

  manage_aws_auth_configmap = true
  aws_auth_roles            = [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]

  fargate_profiles = {
    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    }
    kube-system = {
      selectors = [
        { namespace = "kube-system" }
      ]
    }
  }

  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.name
  })
}