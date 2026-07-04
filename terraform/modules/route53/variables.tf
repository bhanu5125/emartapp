variable "domain_name" {
  description = "Root domain name managed in Route53 (e.g. bhanu5125.shop)"
  type        = string
}

variable "create_zone" {
  description = "Whether to create a new hosted zone for domain_name. Set to false to use an existing zone (e.g. one already registered with a domain registrar and delegated to Route53)."
  type        = bool
  default     = false
}

variable "subdomain" {
  description = "Subdomain to point at the ingress load balancer, e.g. \"emart\" for emart.<domain_name>"
  type        = string
  default     = "emart"
}

variable "record_type" {
  description = "DNS record type for the app record. Use CNAME when target is a load balancer hostname (e.g. an ELB/NLB DNS name from the nginx-ingress Service)."
  type        = string
  default     = "CNAME"
}

variable "ttl" {
  description = "TTL in seconds for the DNS record"
  type        = number
  default     = 300
}

variable "target" {
  description = "DNS target the app record points to - the external hostname of the nginx-ingress controller's LoadBalancer Service (kubectl get svc -n ingress-nginx). Only known after the ingress controller is deployed to the cluster."
  type        = string
}
