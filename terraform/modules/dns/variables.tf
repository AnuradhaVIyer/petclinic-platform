variable "project" {
  description = "Project name used for resource naming"
  type        = string
  default     = "petclinic"
}

variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "domain_name" {
  description = "Existing Route 53 hosted zone domain name"
  type        = string
  default     = ""   # Empty string disables DNS/ingress resources when not set

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?)+\\.?$", var.domain_name))
    error_message = "domain_name must be a valid DNS domain, such as example.com."
  }
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider ARN for the AWS Load Balancer Controller IRSA role"
  type        = string
}

variable "oidc_provider_url" {
  description = "EKS OIDC provider URL for the AWS Load Balancer Controller IRSA trust policy"
  type        = string
}

variable "create_app_record" {
  description = "Whether to create the Route 53 alias record for the Ingress-managed ALB"
  type        = bool
  default     = false
}

variable "alb_name" {
  description = "Name of the ALB created by the Kubernetes Ingress"
  type        = string
  default     = "petclinic-dev-alb"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
