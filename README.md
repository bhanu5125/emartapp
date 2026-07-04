# E-Mart

A polyglot, microservices-based e-commerce application with a full DevOps delivery pipeline — from local Docker Compose to production on AWS EKS, provisioned with Terraform and deployed via Jenkins.

Live: [emart.bhanu5125.shop](https://emart.bhanu5125.shop)

## Architecture

```
                        ┌─────────────┐
                        │   Ingress   │  nginx-ingress + cert-manager (Let's Encrypt TLS)
                        │ emart.bhanu5125.shop
                        └──────┬──────┘
              ┌────────────────┼────────────────┐
              │                │                │
        /  ┌───────┐   /api ┌────────┐  /webapi ┌────────┐
           │ client │        │ nodeapi │          │ javaapi │
           │Angular │        │Node/Express│       │Spring Boot│
           │ :4200  │        │  :5000  │          │  :9000  │
           └────────┘        └────┬────┘          └────┬────┘
                                   │                    │
                              ┌────▼────┐          ┌────▼────┐
                              │ MongoDB │          │  MySQL  │
                              │ (users, │          │ (books) │
                              │  shop)  │          │         │
                              └─────────┘          └─────────┘
```

- **client** — Angular 12 SPA (product catalog, cart, orders, auth guards)
- **nodeapi** — Node.js/Express REST API backed by MongoDB (users, products, categories, orders)
- **javaapi** — Spring Boot REST API backed by MySQL (books domain)
- **nginx** — reverse proxy / API gateway routing `/`, `/api`, `/webapi` to the three services

## Repository layout

```
client/                 Angular frontend
nodeapi/                Node.js/Express API (MongoDB)
javaapi/                Spring Boot API (MySQL)
nginx/                  Reverse proxy configs (local + gateway variants)
docker-compose.yaml     Local multi-container stack (client, nodeapi, javaapi, nginx, MongoDB, MySQL)
Dockerfile              Combined client+nodeapi image (SPA served from Express)
Jenkinsfile             CI/CD: build → Trivy scan → push to ECR → deploy to EKS
kkartchart/             Helm chart (frontend, backend, database subcharts) for Kubernetes deploys
emart-ingress.yaml      Kubernetes Ingress (TLS via cert-manager, path-based routing)
cluster-enc.yaml        cert-manager ClusterIssuer (Let's Encrypt production)
coredns-fixed.yaml      Patched CoreDNS Corefile for EKS DNS resolution
terraform/              IaC for AWS: VPC, EKS, ECR modules + prod environment
```

## Infrastructure & DevOps

**Containerization**
- Each service (`client`, `nodeapi`, `javaapi`) has its own `Dockerfile`.
- `docker-compose.yaml` runs the full stack locally: Angular client, Node API, Spring Boot API, nginx, MongoDB, and MySQL.

**Infrastructure as Code (Terraform)**
- `terraform/modules/vpc` — VPC, public/private subnets.
- `terraform/modules/eks` — EKS cluster, node group, and IAM roles/policies.
- `terraform/modules/ecr` — ECR repositories for the service images.
- `terraform/modules/route53` — scaffolded for DNS automation (not yet wired into the `prod` environment; the production hostname is currently managed outside Terraform).
- `terraform/environments/prod` — composes the VPC, EKS, and ECR modules with an S3 remote state backend.

**Kubernetes**
- `kkartchart/` is a Helm chart with `frontend`, `backend`, and `database` subcharts deploying the client, node/java APIs, MongoDB, and MySQL to the cluster.
- `emart-ingress.yaml` exposes the app through nginx-ingress with TLS issued by cert-manager (`cluster-enc.yaml`, Let's Encrypt production issuer) on `emart.bhanu5125.shop`.
- `coredns-fixed.yaml` addresses in-cluster DNS resolution issues on EKS.

**CI/CD (Jenkins)**
- Root `Jenkinsfile`: builds Docker images for all three services in parallel, scans them with **Trivy** for HIGH/CRITICAL vulnerabilities, pushes to **ECR**, then rolls out the update to **EKS** via `kubectl set image`.
- Per-service `Jenkinsfile`s (`client/`, `javaapi/`) target a Helm-based deploy path (`helm upgrade` against `kkartchart`) for an alternate/legacy registry target.

## Running locally

```bash
docker-compose up --build
```

- Client: http://localhost:4200
- Node API: http://localhost:5000
- Java API: http://localhost:9000
- Combined (via nginx): http://localhost

## Deploying to AWS

```bash
cd terraform/environments/prod
terraform init
terraform apply
```

Provisions the VPC, EKS cluster, and ECR repositories. The Jenkins pipeline then builds, scans, pushes, and rolls out images to the cluster; `kkartchart` and `emart-ingress.yaml` handle the Kubernetes-level deployment and TLS-terminated routing.
