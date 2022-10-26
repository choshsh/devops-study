module "addon_before" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.13.1"

  eks_cluster_id = module.eks.eks_cluster_id

  # EKS Addons
  enable_amazon_eks_vpc_cni = true
  #  amazon_eks_vpc_cni_config = {
  #    most_recent       = true
  #    resolve_conflicts = "OVERWRITE"
  #  }
}

module "addon_after" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.13.1"

  eks_cluster_id = module.eks.eks_cluster_id

  enable_amazon_eks_coredns = true
  #  amazon_eks_coredns_config = {
  #    most_recent       = true
  #    resolve_conflicts = "OVERWRITE"
  #  }

  enable_amazon_eks_aws_ebs_csi_driver = true
  #  amazon_eks_aws_ebs_csi_driver_config = {
  #    most_recent       = true
  #    resolve_conflicts = "OVERWRITE"
  #  }

  #K8s Add-ons
  enable_aws_load_balancer_controller = true
  enable_cluster_autoscaler           = true
  enable_metrics_server               = true

  depends_on = [module.eks]
}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters        = [
      {
        name    = module.eks.eks_cluster_id
        cluster = {
          certificate-authority-data = module.eks.eks_cluster_certificate_authority_data
          server                     = module.eks.eks_cluster_endpoint
        }
      }
    ]
    contexts = [
      {
        name    = "terraform"
        context = {
          cluster = module.eks.eks_cluster_id
          user    = "terraform"
        }
      }
    ]
    users = [
      {
        name = "terraform"
        user = {
          token = data.aws_eks_cluster_auth.this.token
        }
      }
    ]
  })
}

resource "null_resource" "kubectl_set_env" {
  triggers = {
    cluster_id = module.eks.eks_cluster_id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }

    # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
    command = <<-EOT
      kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      kubectl set env daemonset aws-node -n kube-system WARM_PREFIX_TARGET=1 --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      kubectl set env daemonset aws-node -n kube-system ENABLE_POD_ENI=true --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      kubectl patch daemonset aws-node -n kube-system -p '{"spec": {"template": {"spec": {"initContainers": [{"env":[{"name":"DISABLE_TCP_EARLY_DEMUX","value":"true"}],"name":"aws-vpc-cni-init"}]}}}}' --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}' --kubeconfig <(echo $KUBECONFIG | base64 --decode)
    EOT
  }

  depends_on = [module.addon_after]
}