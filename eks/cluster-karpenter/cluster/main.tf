locals {
  karpenter_discovery_tag = var.eks_discovery_tag
}

data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true
  cluster_addons                 = var.cluster_addons

  # -----------------------------------------------------------------------
  # 네트워크
  # -----------------------------------------------------------------------
  vpc_id                   = var.vpc_id
  control_plane_subnet_ids = var.control_plane_subnet_ids
  subnet_ids               = var.subnet_ids

  cluster_security_group_additional_rules = {
    node_to_cluster = {
      description                = "Node to Cluster"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_node_security_group = true
    }
    cluster_to_node = {
      description                = "Cluster to Node"
      protocol                   = "all"
      from_port                  = 0
      to_port                    = 0
      type                       = "egress"
      source_node_security_group = true
    }
  }

  create_node_security_group = false
  node_security_group_id     = aws_security_group.eks_node.id

  # -----------------------------------------------------------------------
  # 인증
  # -----------------------------------------------------------------------
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  kms_key_administrators                   = [data.aws_caller_identity.current.arn]

  # -----------------------------------------------------------------------
  # Fargate
  # -----------------------------------------------------------------------
  fargate_profiles = {
    controller = {
      selectors = [
        { namespace = "karpenter" },
        {
          namespace = "kube-system"
          labels = {
            "eks.amazonaws.com/component" = "coredns"
          }
        },
        {
          namespace = "kube-system"
          labels = {
            "app.kubernetes.io/name" = "aws-load-balancer-controller"
          }
        }
      ]
      timeouts = {
        create = "15m"
        delete = "15m"
      }
    }
  }

  tags = merge(var.tags, local.karpenter_discovery_tag)
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    type                        = "gp3"
    "csi.storage.k8s.io/fstype" = "ext4"
  }
}

module "eks-aws-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.31.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.karpenter.instance_profile_arn
      username = "system:node:{{SessionName}}"
      groups   = ["system:bootstrappers", "system:nodes", "system:node-proxier"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = data.aws_caller_identity.current.arn
      username = data.aws_caller_identity.current.id
      groups   = ["system:masters"]
    },
  ]

  depends_on = [module.eks]
}
