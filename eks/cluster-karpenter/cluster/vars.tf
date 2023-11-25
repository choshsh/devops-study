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

variable "fargate_profiles" {
  description = "클러스터의 Fargate 프로파일. (namespace: Fargate 프로파일의 네임스페이스. labels: Fargate 프로파일의 레이블 셀렉터 (네임스페이스 전체 적용 시 []))"
  type = map(object({
    namespace = string
    labels    = map(string)
  }))
  default = {}
}

