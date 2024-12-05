variable "region" {
  description = "리전"
  type        = string
}

variable "cluster_name" {
  description = "클러스터의 이름"
  type        = string
}

variable "cluster_version" {
  description = "클러스터의 버전"
  type        = string
}

variable "vpc_id" {
  description = "클러스터의 VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "클러스터의 서브넷 ID"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "클러스터의 컨트롤 플레인 서브넷 ID"
  type        = list(string)
}

variable "cluster_addons" {
  description = "클러스터의 애드온. Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#addons"
  type = map(object({
    addon_version        = string
    configuration_values = string
  }))
  default = {}
}

variable "tags" {
  description = "클러스터의 태그"
  type        = map(string)
  default     = {}
}

variable "eks_discovery_tag" {
  description = "EKS 클러스터를 찾기 위한 태그"
  type        = map(number)
}

variable "ecr_token" {
  description = "ECR 토큰"
  type        = any
}

variable "helm_chart_versions" {
  description = "Helm 차트들의 버전"
  type = object({
    aws_load_balancer_controller = string
    karpenter                    = string
  })
  default = {
    aws_load_balancer_controller = "1.10.1"
    karpenter                    = "1.1.0"
  }
}
