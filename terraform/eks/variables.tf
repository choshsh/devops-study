variable "workspace" {
  description = "Terraform workspace"
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}
