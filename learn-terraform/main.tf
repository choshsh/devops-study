locals {
  workspace = terraform.workspace == "default" ? "dev" : "prod"
}

module "vpc" {
  source    = "./vpc"
  workspace = local.workspace
}

# module "eks" {
#   source              = "./eks"
#   eks_cluster_version = "1.21"
#   subnet_ids          = module.vpc.subnet_ids
#   workspace           = local.workspace
#   depends_on          = [module.vpc]
# }


data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_key_pair" "ssh-keypair" {
  key_name   = "ssh-keypair"
  public_key = file("./ssh-key/aws-key.pub")
}


# EC2
resource "aws_instance" "test" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-0f9673174f0dcce4c"
  vpc_security_group_ids      = [module.vpc.default_sg_id]
  key_name                    = aws_key_pair.ssh-keypair.key_name
  depends_on = [
    module.vpc
  ]
}
resource "aws_instance" "test2" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-03d5d75c7591de6a8"
  vpc_security_group_ids      = [module.vpc.default_sg_id]
  key_name                    = aws_key_pair.ssh-keypair.key_name
  depends_on = [
    module.vpc
  ]
}
