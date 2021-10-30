locals {
  workspace = terraform.workspace == "default" ? "dev" : "prod"
}

module "vpc" {
  source = "./network"

  workspace  = local.workspace
  cidr_block = var.cidr_block
}


module "eks" {
  source = "./eks"

  eks_cluster_version = var.eks_cluster_version
  private_subnet_ids  = module.vpc.private_subnet_ids
  eks_node_group      = var.eks_node_group
  fargate_profiles    = var.fargate_profiles
  workspace           = local.workspace
  depends_on          = [module.vpc]
}
