locals {
  aws_profile = "choshsh"

  name   = "choshsh-eks-cluster"
  region = "us-east-1"
  eks_discovery_tag = {
    "eks:discovery:${local.name}" = "1"
  }
}

variable "env" {
  description = "환경"
  type        = string
  default     = "test"
}
