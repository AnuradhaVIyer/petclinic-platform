variable "project" {
  description = "Project name used as the ECR repository prefix"
  type        = string
  default     = "petclinic"
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "service_names" {
  description = "Service names for ECR repositories"
  type        = set(string)

  validation {
    condition     = length(var.service_names) > 0
    error_message = "At least one service name must be provided."
  }

  validation {
    condition = alltrue([
      for name in var.service_names :
      can(regex("^[a-z0-9]+(?:[._/-][a-z0-9]+)*$", name))
    ])
    error_message = "Service names must be valid ECR repository path components: lowercase letters, numbers, and separators ., _, -, /."
  }
}

variable "tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}
