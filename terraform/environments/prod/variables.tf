variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "emart-eks"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "instance_types" {
  description = "List of EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "domain_name" {
  description = "Root domain name managed in Route53"
  type        = string
  default     = "bhanu5125.shop"
}

variable "create_zone" {
  description = "Whether Terraform should create the Route53 hosted zone. Leave false if the zone already exists (e.g. registered elsewhere and delegated to Route53)."
  type        = bool
  default     = false
}

variable "subdomain" {
  description = "Subdomain the app is served on, e.g. \"emart\" for emart.<domain_name>"
  type        = string
  default     = "emart"
}

variable "ingress_lb_hostname" {
  description = "External hostname of the nginx-ingress controller's LoadBalancer Service. Deploy the ingress controller first (helm install ingress-nginx ...), then run: kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' and pass the result via -var ingress_lb_hostname=..."
  type        = string
  default     = ""
}
