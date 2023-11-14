# -------------------------------------------------------------------------------
# ArgoCD
# - GitOps 도구
# - https://argo-cd.readthedocs.io/en/stable/
# -------------------------------------------------------------------------------
resource "helm_release" "argocd" {
  namespace        = var.argocd_chart.namespace
  repository       = var.argocd_chart.repository
  create_namespace = true

  name    = var.argocd_chart.name
  chart   = var.argocd_chart.chart
  version = var.argocd_chart.version

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml
  values = [
    templatefile("${path.module}/values/argocd.yml", {
      admin_password          = var.argocd_admin_password
      githubAppID             = var.argocd_github_app_id
      githubAppInstallationID = var.argocd_github_app_installation_id
      githubAppPrivateKey     = file(format("%s/%s", path.module, var.argocd_github_app_private_key_path))
    })
  ]
}

# -------------------------------------------------------------------------------
# ArgoCD Rollouts
# - ArgoCD 플러그인으로 Blue/Green 또는 Canary 배포를 지원하는 툴
# - https://argoproj.github.io/argo-rollouts/
# -------------------------------------------------------------------------------
resource "helm_release" "argo_rollouts" {
  namespace        = var.argo_rollouts_chart.namespace
  repository       = var.argo_rollouts_chart.repository
  create_namespace = true

  name    = var.argo_rollouts_chart.name
  chart   = var.argo_rollouts_chart.chart
  version = var.argo_rollouts_chart.version

  depends_on = [helm_release.argocd]
}
