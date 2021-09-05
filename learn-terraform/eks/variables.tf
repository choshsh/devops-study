variable "workspace" {
  type        = string
  description = "Terraform workspace"
}

variable "eks_cluster_version" {
  type        = string
  description = "Kubernetes version"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
}
