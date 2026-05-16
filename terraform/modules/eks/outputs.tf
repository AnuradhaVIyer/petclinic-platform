output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider (without https:// prefix)"
  value       = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}

output "node_group_name" {
  description = "Name of the managed node group"
  value       = aws_eks_node_group.main.node_group_name
}

output "node_role_arn" {
  description = "ARN of the node IAM role"
  value       = aws_iam_role.node.arn
}

output "kubeconfig_command" {
  description = "Command to update kubeconfig for cluster access"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${data.aws_region.current.name}"
}
