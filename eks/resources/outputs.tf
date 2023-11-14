output "istio_ingress_app_selector" {
  value = helm_release.istio-ingress.name
}