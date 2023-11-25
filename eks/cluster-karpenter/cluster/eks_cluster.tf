data "aws_ecrpublic_authorization_token" "token" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.20.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = var.cluster_addons

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = true
  create_node_security_group    = true

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]

  #  fargate_profiles = {
  #    karpenter = {
  #      selectors = [
  #        { namespace = "karpenter" }
  #      ]
  #    }
  #    kube-system = {
  #      selectors = [
  #        { namespace = "kube-system" }
  #      ]
  #    }
  #  }

  tags = merge(var.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  })
}
