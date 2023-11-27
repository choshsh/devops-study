data "aws_ecrpublic_authorization_token" "token" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.20.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = var.cluster_addons

  vpc_id                   = var.vpc_id
  control_plane_subnet_ids = var.control_plane_subnet_ids
  subnet_ids               = var.subnet_ids

  # Fargate profiles use the cluster primary security group so these are not utilized
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
      timeouts = {
        create = "15m"
        delete = "15m"
      }
    }
    coredns = {
      selectors = [
        {
          namespace = "kube-system"
          labels    = {
            "eks.amazonaws.com/component" = "coredns"
          }
        }
      ]
      timeouts = {
        create = "15m"
        delete = "15m"
      }
    }
  }

  tags = merge(var.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  })
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name        = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters             = {
    type                        = "gp3"
    "csi.storage.k8s.io/fstype" = "ext4"
  }
}