locals {
  workspace = terraform.workspace == "default" ? "dev" : "prod"
}

data "aws_route53_zone" "selected" {
  name = "${var.domain}."
}

data "aws_lb" "nlb" {
  tags = {
    "kubernetes.io/service-name" = "istio-system/istio-ingressgateway"
  }

}

resource "aws_route53_record" "alias" {
  for_each = toset(var.domain_alias)

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${each.value}.${var.domain}"
  type    = "A"

  alias {
    name                   = data.aws_lb.nlb.dns_name
    zone_id                = data.aws_lb.nlb.zone_id
    evaluate_target_health = true
  }

  depends_on = [data.aws_lb.nlb]
}
