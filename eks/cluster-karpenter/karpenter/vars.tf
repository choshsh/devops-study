variable "karpenter_role_name" {
  description = "The name of the IAM role to create for Karpenter"
  type        = string
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster to create for Karpenter"
  type        = string
}

variable "azs" {
    description = "The availability zones to use for the EKS cluster"
    type        = list(string)
}