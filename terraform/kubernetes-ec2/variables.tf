variable "global_name" {
  description = "Global name"
  type        = string
  default     = "choshsh"
}

variable "cidr_block" {
  description = "Input VPC CIDR block like 192.168.0.0/16.\n\n\tSubnets will created like below.\n\t- Public Subnets : [192.168.0.0/27, 192.168.1.0/27]\n\t- Private Subnets : [192.168.2.0/27, 192.168.3.0/27]\n\n\t1 Public subnet and 1 private subnet will be placed in same availability zone.\n\t- Availability Zones #1 : [192.168.0.0/27, 192.168.2.0/27]\n\t- Availability Zones #2 : [192.168.1.0/27, 192.168.3.0/27]"
  type        = string
  validation {
    condition     = length(split(".", var.cidr_block)) == 4 && tonumber(split(".", var.cidr_block)[0]) <= 255 && tonumber(split(".", var.cidr_block)[1]) <= 255
    error_message = "Sample: 192.168.0.0/16."
  }
}

variable "domain" {
  description = "Domain name. Ex) choshsh.com"
  type        = string
}

variable "domain_alias" {
  description = "Domain name. Ex) www"
  type        = list(string)
}

# EC2
variable "master_node_count" {
  description = "How many master nodes"
  type        = number
  default     = 1
}

variable "master_node_instance_type" {
  description = "How many master nodes"
  type        = string
  default     = "t4g.medium"
}

variable "worker_node_count" {
  description = "How many worker nodes"
  type        = number
  default     = 2
}

variable "worker_node_instance_type" {
  description = "How many worker nodes"
  type        = string
  default     = "t4g.medium"
}
