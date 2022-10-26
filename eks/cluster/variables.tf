variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "access_allow_ips" {
  type = list(string)
  description = "CIDR block that you want to allow access to EKS Endpoint"
  default = ["0.0.0.0/0"]
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
  description = "vpc cidr like 10.0.0.0/16"
}


# Just for default value.
variable "nodegroup_default" {
  type = object({
    create_launch_template = bool
    launch_template_os     = string
    kubelet_extra_args     = string
    bootstrap_extra_args   = string
    enable_monitoring      = bool
    eni_delete             = bool
    block_device_mappings  = list(any)
    subnet_type            = string
  })

  default = {
    create_launch_template = "true"
    launch_template_os     = "amazonlinux2eks"

    kubelet_extra_args   = "--max-pods=110"
    bootstrap_extra_args = "--container-runtime containerd --use-max-pods false"

    enable_monitoring = true
    eni_delete        = true

    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        volume_type = "gp3"
        volume_size = 150
      }
    ]

    subnet_type = "private"
  }
}

variable "node_security_group_additional_rules" {
  type = object({
    ingress_self_all = object({
      description = string
      protocol    = string
      from_port   = number
      to_port     = number
      type        = string
      self        = bool
    })
    egress_all = object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      type             = string
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
    })
    ingress_cluster_to_node_all_traffic = object({
      description                   = string
      protocol                      = string
      from_port                     = number
      to_port                       = number
      type                          = string
      source_cluster_security_group = bool
    })
  })

  default = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
}