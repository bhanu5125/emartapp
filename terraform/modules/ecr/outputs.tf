output "emart_client_repository_url" {
  description = "URL of the emart/client ECR repository"
  value       = aws_ecr_repository.emart_client.repository_url
}

output "emart_nodeapi_repository_url" {
  description = "URL of the emart/nodeapi ECR repository"
  value       = aws_ecr_repository.emart_nodeapi.repository_url
}

output "emart_javaapi_repository_url" {
  description = "URL of the emart/javaapi ECR repository"
  value       = aws_ecr_repository.emart_javaapi.repository_url
}
