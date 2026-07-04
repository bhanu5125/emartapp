output "zone_id" {
  description = "Route53 hosted zone ID for domain_name"
  value       = local.zone_id
}

output "name_servers" {
  description = "Authoritative name servers, only populated when create_zone is true - set these at your domain registrar to delegate the domain to Route53"
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : null
}

output "fqdn" {
  description = "Fully-qualified domain name of the created app record"
  value       = aws_route53_record.app.fqdn
}
