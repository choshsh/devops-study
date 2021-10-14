variable "global_name" {
  description = "Global name"
  type        = string
}

variable "workspace" {
  description = "Terraform workspace"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block. Ex) xxx.xxx.0.0/16"
  type        = string
}

variable "domain" {
  description = "Domain name. Ex) choshsh.com"
  type        = string
}

variable "domain_alias" {
  description = "Domain name. Ex) www"
  type        = list(string)
}
