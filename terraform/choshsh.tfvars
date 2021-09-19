cidr_block = "192.168.0.0/16"

eks_cluster_version = "1.21"

eks_node_group = {
  name          = "choshsh"
  min_size      = 1
  max_size      = 3
  desired_size  = 1
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
