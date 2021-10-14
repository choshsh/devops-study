data "aws_route53_zone" "selected" {
  name = "${var.domain}."
}

resource "aws_route53_record" "alias" {
  for_each = toset(var.domain_alias)

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${each.value}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_lb.public]
}
