# -------------------------------------------------------------------------------
# Helm Chart
# -------------------------------------------------------------------------------
variable "argocd_chart" {
  description = "ArgoCD chart"
  type = object({
    name       = string
    namespace  = string
    repository = string
    chart      = string
    version    = string
  })
  default = {
    name       = "argocd"
    namespace  = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart      = "argo-cd"
    version    = "5.51.1"
  }
}


variable "argocd_admin_password" {
  description = <<EOF
admin password 암호화 가이드

$ ARGO_PWD='example'
$ htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/'
EOF
  type        = string
}

variable "argocd_github_app_id" {
  description = "ArgoCD Github App ID (ref: https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/#github-app-credential)"
  type        = string
}

variable "argocd_github_app_installation_id" {
  description = "ArgoCD Github App Installation ID"
  type        = string
}

variable "argocd_github_app_private_key_path" {
  description = "ArgoCD Github App private key path"
  type        = string
}

variable "argo_rollouts_chart" {
  description = "Argo Rollouts chart"
  type = object({
    name       = string
    namespace  = string
    repository = string
    chart      = string
    version    = string
  })
  default = {
    name       = "argo-rollouts"
    namespace  = "argo-rollouts"
    repository = "https://argoproj.github.io/argo-helm"
    chart      = "argo-rollouts"
    version    = "2.31.1"
  }
}

variable "istio_chart" {
  description = "Istio chart"
  type = object({
    repository = string
    version    = string

    namespace = string

    base_name  = string
    base_chart = string

    istiod_name  = string
    istiod_chart = string

    gateway_name  = string
    gateway_chart = string
  })
  default = {
    repository = "https://istio-release.storage.googleapis.com/charts"
    version    = "1.19.4"

    namespace = "istio-system"

    base_name  = "istio-base"
    base_chart = "base"

    istiod_name  = "istiod"
    istiod_chart = "istiod"

    gateway_name  = "istio-ingress"
    gateway_chart = "gateway"

  }
}