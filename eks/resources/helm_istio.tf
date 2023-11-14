# -------------------------------------------------------------------------------
# Istio
# - 네트워크 트래픽을 관리하고 보안을 제공하는 서비스 메시
# - https://istio.io/
# -------------------------------------------------------------------------------
resource "helm_release" "istio-base" {
  namespace        = var.istio_chart.namespace
  repository       = var.istio_chart.repository
  create_namespace = true

  name    = var.istio_chart.base_name
  chart   = var.istio_chart.base_chart
  version = var.istio_chart.version
}

# -------------------------------------------------------------------------------
# Istio Control Plane
# - Istio Control Plane은 Istio의 핵심 구성 요소로서, 서비스 메시의 데이터 플레인과 제어 플레인을 구성하는 구성 요소를 포함
# -------------------------------------------------------------------------------
resource "helm_release" "istiod" {
  namespace  = var.istio_chart.namespace
  repository = var.istio_chart.repository

  name    = var.istio_chart.istiod_name
  chart   = var.istio_chart.istiod_chart
  version = var.istio_chart.version

  # https://github.com/istio/istio/blob/master/manifests/charts/istio-control/istio-discovery/values.yaml
  values = [
    file("${path.module}/values/istiod.yml")
  ]

  depends_on = [helm_release.istio-base]
}

# -------------------------------------------------------------------------------
# Istio Ingress Gateway
# - Istio Ingress Gateway는 클러스터 외부에서 클러스터 내부로의 트래픽을 제어하는 역할을 수행
# -------------------------------------------------------------------------------
resource "helm_release" "istio-ingress" {
  namespace  = var.istio_chart.namespace
  repository = var.istio_chart.repository

  name    = var.istio_chart.gateway_name
  chart   = var.istio_chart.gateway_chart
  version = var.istio_chart.version

  # https://github.com/istio/istio/blob/master/manifests/charts/gateway/values.yaml
  values = [
    file("${path.module}/values/istio_ingress.yml")
  ]

  depends_on = [helm_release.istiod]
}