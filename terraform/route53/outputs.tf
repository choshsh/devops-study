output "route53-public-domain" {
  description = "route53-public-domains"
  value       = [for s in aws_route53_record.alias : s.name]
}
