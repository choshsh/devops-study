data "aws_ssm_parameter" "eks_ami_arm" {
  name = "/aws/service/eks/optimized-ami/1.23/amazon-linux-2-arm64/recommended/image_id"
}

data "aws_ssm_parameter" "eks_ami_x86" {
  name = "/aws/service/eks/optimized-ami/1.23/amazon-linux-2/recommended/image_id"
}

module "eks" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.13.1"

  # EKS CLUSTER
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_enabled_log_types            = []
  node_security_group_additional_rules = var.node_security_group_additional_rules

  cluster_endpoint_public_access_cidrs = var.access_allow_ips

  managed_node_groups = {
    spot_2 = merge(var.nodegroup_default, {
      node_group_name = "eks-spot-2"

      custom_ami_id  = data.aws_ssm_parameter.eks_ami_x86.value
      capacity_type  = "SPOT"  # ON_DEMAND or SPOT
      instance_types = ["m6i.large", "c6i.large", "r6i.large"]

      desired_size = 2
      max_size     = 10
      min_size     = 2
      percentage   = 20
    })
  }

  tags = {
    Worksapce = terraform.workspace
  }

  depends_on = [module.vpc]
}

resource "kubernetes_namespace" "ns_monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }

    name = "monitoring"
  }

  depends_on = [module.eks]
}

resource "helm_release" "prometheus" {
  name = "p"

  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  namespace  = "monitoring"

  depends_on = [kubernetes_namespace.ns_monitoring]
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name        = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters          = {
    type   = "gp3"
    fsType = "ext4"
  }

  depends_on = [module.eks]
}