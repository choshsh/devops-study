locals {
  workspace = terraform.workspace == "default" ? "dev" : "prod"
}

module "vpc" {
  source = "./vpc"

  workspace = local.workspace
}

module "eks" {
  source = "./eks"

  eks_cluster_version = "1.21"
  private_subnet_ids  = module.vpc.private_subnet_ids
  workspace           = local.workspace
  depends_on          = [module.vpc]
}

# # public, private 네트워크 테스트
# module "test" {
#   source             = "./test"
#   public_subnet_ids  = module.vpc.public_subnet_ids
#   private_subnet_ids = module.vpc.private_subnet_ids
#   linux_sg_id        = module.vpc.linux_sg_id
#   workspace          = local.workspace
#   depends_on = [
#     module.vpc
#   ]
# }
# output "public-ec2-public-ip" {
#   value = module.test.public-ec2-public-ip
# }
# output "private-ec2-private-ip" {
#   value = module.test.private-ec2-private-ip
# }

