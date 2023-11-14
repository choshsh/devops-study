#terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 5.0"
#    }
#  }
#
#  backend "s3" {
#    bucket               = "terraform-backend"
#    key                  = "terraform.tfstate"
#    region               = "ap-northeast-2"
#    workspace_key_prefix = "eks/v2/resources"
#  }
#}
#
## Configure the AWS Provider
#provider "aws" {
#  region  = "ap-northeast-2"
#  profile = terraform.workspace
#
#  # Make it faster by skipping something
#  skip_metadata_api_check     = true
#  skip_region_validation      = true
#  skip_credentials_validation = true
#}
#
#provider "aws" {
#  region  = "us-east-1"
#  alias   = "virginia"
#  profile = terraform.workspace
#
#  skip_metadata_api_check     = true
#  skip_region_validation      = true
#  skip_credentials_validation = true
#}
#
#provider "aws" {
#  region  = "ap-northeast-2"
#  alias   = "production"
#  profile = "production"
#
#  skip_metadata_api_check     = true
#  skip_region_validation      = true
#  skip_credentials_validation = true
#}
#
#data "aws_region" "current" {}
#data "aws_caller_identity" "current" {}
#
#data "aws_eks_cluster" "this" {
#  name = data.terraform_remote_state.eks.outputs.cluster.cluster_name
#}
#
#data "aws_eks_cluster_auth" "this" {
#  name = data.terraform_remote_state.eks.outputs.cluster.cluster_name
#}
#
## -------------------------------------------------------------------------------
## Provider
## -------------------------------------------------------------------------------
#provider "kubernetes" {
#  host                   = data.aws_eks_cluster.this.endpoint
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0]["data"])
#  token                  = data.aws_eks_cluster_auth.this.token
#
#  exec {
#    api_version = "client.authentication.k8s.io/v1beta1"
#    command     = "aws"
#    # This requires the awscli to be installed locally where Terraform is executed
#    args = [
#      "eks", "get-token",
#      "--cluster-name", data.terraform_remote_state.eks.outputs.cluster.cluster_name,
#      "--profile", terraform.workspace
#    ]
#  }
#}
#
#provider "helm" {
#  kubernetes {
#    host                   = data.aws_eks_cluster.this.endpoint
#    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0]["data"])
#    token                  = data.aws_eks_cluster_auth.this.token
#
#    exec {
#      api_version = "client.authentication.k8s.io/v1beta1"
#      command     = "aws"
#      # This requires the awscli to be installed locally where Terraform is executed
#      args = [
#        "eks", "get-token",
#        "--cluster-name", data.terraform_remote_state.eks.outputs.cluster.cluster_name,
#        "--profile", terraform.workspace
#      ]
#    }
#  }
#}