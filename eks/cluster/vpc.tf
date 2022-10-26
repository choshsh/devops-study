locals {
  my_subnets  = cidrsubnets(var.vpc_cidr, 6, 6, 6, 6, 4, 4, 4, 4)
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.available.names

  public_subnets   = slice(local.my_subnets, 0, 2)
  database_subnets = slice(local.my_subnets, 2, 4)
  private_subnets  = slice(local.my_subnets, 4, 8)

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}