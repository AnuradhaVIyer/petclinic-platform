output "zone_id" {
  description = "Route 53 hosted zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

output "zone_name_servers" {
  description = "Name servers for the existing Route 53 hosted zone"
  value       = data.aws_route53_zone.main.name_servers
}

output "name_servers" {
  description = "Name servers for the existing Route 53 hosted zone"
  value       = data.aws_route53_zone.main.name_servers
}

output "certificate_arn" {
  description = "Validated ACM certificate ARN"
  value       = aws_acm_certificate_validation.wildcard.certificate_arn
}

output "app_record_fqdn" {
  description = "Application Route 53 record FQDN"
  value       = var.create_app_record ? aws_route53_record.app[0].fqdn : null
}

output "lb_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller service account"
  value       = aws_iam_role.lb_controller.arn
}

output "lb_controller_policy_arn" {
  description = "IAM policy ARN for the AWS Load Balancer Controller"
  value       = aws_iam_policy.lb_controller.arn
}
