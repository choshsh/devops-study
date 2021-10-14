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

variable "eks_node_group" {
  description = "Node-group config"
  type        = map(string)
}

variable "fargate_profiles" {
  description = "Fargate profiles"
  type        = list(any)
}
