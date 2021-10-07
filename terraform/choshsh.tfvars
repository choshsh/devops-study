cidr_block = "192.168.0.0/16"

# Input whether to create k8s cluster as EKS(SaaS) or EC2 (0: EC2 / 1: EKS)
eks_enable = 0

# EKS config
eks_cluster_version = "1.21"

eks_node_group = {
  name          = "choshsh"
  min_size      = 2
  max_size      = 4
  desired_size  = 2
  ami_type      = "AL2_x86_64"
  instance_type = "t3.medium"
}

fargate_profiles = [
  {
    name      = "default",
    namespace = "default",
    labels = {
      compute-type = "fargate"
    }
  },
  {
    name      = "dev",
    namespace = "dev",
    labels = {
      compute-type = "fargate"
    }
  },
  {
    name      = "argocd",
    namespace = "argocd",
    // all
    labels = {}
  },
]

# EC2 config
master_node_count         = 1
master_node_instance_type = "t3a.medium"
worker_node_count         = 2
worker_node_instance_type = "t3a.medium"
