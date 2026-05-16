output "repository_urls" {
  description = "Map of service name to ECR repository URL"
  value = {
    for service_name, repository in aws_ecr_repository.service :
    service_name => repository.repository_url
  }
}

output "repository_arns" {
  description = "Map of service name to ECR repository ARN"
  value = {
    for service_name, repository in aws_ecr_repository.service :
    service_name => repository.arn
  }
}

output "image_tag_mutability" {
  description = "Effective ECR image tag mutability"
  value       = local.image_tag_mutability
}
