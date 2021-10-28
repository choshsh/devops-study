locals {
  workspace = terraform.workspace == "default" ? "dev" : "prod"
}

module "network" {
  source = "./network"

  workspace    = local.workspace
  cidr_block   = var.cidr_block
  domain       = var.domain
  domain_alias = var.domain_alias
  global_name  = var.global_name
}

module "ec2" {
  source = "./ec2"

  master_node_count         = var.master_node_count
  master_node_instance_type = var.master_node_instance_type
  worker_node_count         = var.worker_node_count
  worker_node_instance_type = var.worker_node_instance_type
  public_subnet_ids         = module.network.public_subnet_ids
  linux_sg_id               = module.network.linux_sg_id
  allow_tls_sg_id           = module.network.allow_tls_sg_id
  global_name               = var.global_name

  depends_on = [module.network]
}
