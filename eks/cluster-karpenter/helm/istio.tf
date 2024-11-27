locals {
  istio = {
    namespace = "istio-system"
    repo      = "https://istio-release.storage.googleapis.com/charts"
    version   = "1.24.1"
  }
  max_history = 5
}

resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = local.istio.namespace
  }
}

resource "helm_release" "istio_base" {
  repository      = "https://istio-release.storage.googleapis.com/charts"
  chart           = "base"
  name            = "istio-base"
  version         = local.istio.version
  namespace       = local.istio.namespace
  max_history     = local.max_history
  upgrade_install = true

  depends_on = [kubernetes_namespace.istio-system]
}

resource "helm_release" "istiod" {
  repository      = local.istio.repo
  chart           = "istiod"
  name            = "istiod"
  version         = local.istio.version
  namespace       = local.istio.namespace
  max_history     = local.max_history
  upgrade_install = true

  dynamic "set" {
    for_each = {
      "profile" = "ambient"

    }
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_cni" {
  repository      = local.istio.repo
  chart           = "cni"
  name            = "istio-cni"
  version         = local.istio.version
  namespace       = local.istio.namespace
  max_history     = local.max_history
  upgrade_install = true

  values = [
    file("${path.module}/values/istio-cni.yaml")
  ]

  depends_on = [helm_release.istiod]
}

resource "helm_release" "ztunnel" {
  repository      = local.istio.repo
  chart           = "ztunnel"
  name            = "ztunnel"
  version         = local.istio.version
  namespace       = local.istio.namespace
  max_history     = local.max_history
  upgrade_install = true

  values = [
    file("${path.module}/values/ztunnel.yaml")
  ]
  depends_on = [helm_release.istio_cni]
}