output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "eks_cluster_sg_id" {
  description = "Security group ID for the EKS cluster"
  value       = module.vpc.eks_cluster_sg_id
}

output "eks_node_sg_id" {
  description = "Security group ID for EKS worker nodes"
  value       = module.vpc.eks_node_sg_id
}

output "rds_sg_id" {
  description = "Security group ID for RDS MySQL"
  value       = module.vpc.rds_sg_id
}

output "alb_sg_id" {
  description = "Security group ID for the ALB"
  value       = module.vpc.alb_sg_id
}

# --- EKS ---

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = module.eks.cluster_ca_certificate
  sensitive   = true
}

output "eks_oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "eks_node_role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = module.eks.node_role_arn
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = module.eks.kubeconfig_command
}

# --- ECR ---

output "ecr_repository_urls" {
  description = "Map of service name to ECR repository URL"
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "Map of service name to ECR repository ARN"
  value       = module.ecr.repository_arns
}

output "ecr_image_tag_mutability" {
  description = "Effective ECR image tag mutability"
  value       = module.ecr.image_tag_mutability
}

# --- RDS ---

output "rds_endpoint" {
  description = "RDS endpoint hostname"
  value       = module.rds.endpoint
}

output "rds_port" {
  description = "RDS port"
  value       = module.rds.port
}

output "rds_db_instance_id" {
  description = "RDS instance ID"
  value       = module.rds.db_instance_id
}

output "rds_secret_arn" {
  description = "Secrets Manager secret ARN for RDS credentials"
  value       = module.rds.secret_arn
}

output "rds_secret_arns" {
  description = "Map of RDS-related Secrets Manager secret ARNs"
  value       = module.rds.secret_arns
}

output "rds_secret_name" {
  description = "Secrets Manager secret name for RDS credentials"
  value       = module.rds.secret_name
}

output "rds_jdbc_url" {
  description = "JDBC URL for the shared petclinic database"
  value       = module.rds.jdbc_url
}

# --- DNS & Ingress ---

/*output "dns_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = module.dns.zone_id
}

output "dns_zone_name_servers" {
  description = "Route 53 hosted zone name servers"
  value       = module.dns.zone_name_servers
}

output "dns_certificate_arn" {
  description = "Validated ACM certificate ARN"
  value       = module.dns.certificate_arn
}

output "dns_app_record_fqdn" {
  description = "Application Route 53 record FQDN"
  value       = module.dns.app_record_fqdn
}

output "lb_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller"
  value       = module.dns.lb_controller_role_arn
}

output "lb_controller_policy_arn" {
  description = "IAM policy ARN for the AWS Load Balancer Controller"
  value       = module.dns.lb_controller_policy_arn
}*/
