variable "karpenter_role_name" {
  description = "The name of the IAM role to create for Karpenter"
  type        = string
}

variable "azs" {
  description = "The availability zones to use for the EKS cluster"
  type        = list(string)
}

variable "eks_discovery_tag" {
  description = "The tag to use for EKS cluster, security_group, subnet discovery"
  type        = map(number)
}