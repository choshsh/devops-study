variable "domain" {
  description = "Domain name. Ex) choshsh.com"
  type        = string
}

variable "domain_alias" {
  description = "Domain name. Ex) [\"www\"]"
  type        = list(string)
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "kubernetes"
}
