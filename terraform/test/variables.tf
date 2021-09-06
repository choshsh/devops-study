variable "workspace" {
  description = "Terraform workspace"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = list(string)
}
variable "linux_sg_id" {
  description = "Defualt Custom Security Group ID"
  type        = string
}
