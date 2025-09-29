output "cluster_id" {
  description = "The EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "The certificate authority data for the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}
