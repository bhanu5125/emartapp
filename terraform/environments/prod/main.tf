terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "emart-project-0505"
    key    = "emart/terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  cluster_name    = var.cluster_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  desired_capacity   = var.desired_capacity
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  instance_types     = var.instance_types
}

module "ecr" {
  source = "../../modules/ecr"
}

module "route53" {
  source = "../../modules/route53"

  domain_name = var.domain_name
  create_zone = var.create_zone
  subdomain   = var.subdomain
  target      = var.ingress_lb_hostname
}
