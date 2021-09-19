variable "cidr_block" {
  description = "Input VPC CIDR block like 192.168.0.0/16.\n\n\tSubnets will created like below.\n\t- Public Subnets : [192.168.0.0/27, 192.168.1.0/27]\n\t- Private Subnets : [192.168.2.0/27, 192.168.3.0/27]\n\n\t1 Public subnet and 1 private subnet will be placed in same availability zone.\n\t- Availability Zones #1 : [192.168.0.0/27, 192.168.2.0/27]\n\t- Availability Zones #2 : [192.168.1.0/27, 192.168.3.0/27]"
  type        = string
  validation {
    condition     = length(split(".", var.cidr_block)) == 4 && tonumber(split(".", var.cidr_block)[0]) <= 255 && tonumber(split(".", var.cidr_block)[1]) <= 255
    error_message = "Sample: 192.168.0.0/16."
  }
}

variable "eks_cluster_version" {
  description = "Input EKS cluster version."
  type        = string
  default     = "1.21"
}

variable "eks_node_group" {
  description = "Node-group config"
  type        = map(string)
}

variable "fargate_profiles" {
  description = "Fargate profiles"
  type        = list(any)
}
