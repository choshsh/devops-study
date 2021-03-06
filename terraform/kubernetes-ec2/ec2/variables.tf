variable "global_name" {
  description = "Global name"
  type        = string
}

variable "linux_sg_id" {
  description = "Defualt Custom Security Group ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "allow_tls_sg_id" {
  description = "In VPC Security Group ID"
  type        = string
}

variable "master_node_count" {
  description = "How many master nodes"
  type        = number
}

variable "master_node_instance_type" {
  description = "How many master nodes"
  type        = string
}

variable "worker_node_count" {
  description = "How many worker nodes"
  type        = number
}

variable "worker_node_instance_type" {
  description = "How many worker nodes"
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "domain" {
  description = "Domain name. Ex) choshsh.com"
  type        = string
}

variable "domain_alias" {
  description = "Domain name. Ex) www"
  type        = list(string)
}
