variable "workspace" {
  description = "Terraform workspace"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block. Ex) xxx.xxx.0.0/16"
  type        = string
}
