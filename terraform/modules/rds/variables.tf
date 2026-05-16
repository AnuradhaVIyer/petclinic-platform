variable "project" {
  description = "Project name used for resource naming and secret paths"
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

variable "subnet_ids" {
  description = "Subnet IDs for the DB subnet group"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnet IDs must be provided for the DB subnet group."
  }
}

variable "security_group_id" {
  description = "RDS security group ID"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial storage in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20
    error_message = "allocated_storage must be at least 20 GB."
  }
}

variable "max_allocated_storage" {
  description = "Maximum autoscaled storage in GB"
  type        = number
  default     = 100

  validation {
    condition     = var.max_allocated_storage > var.allocated_storage
    error_message = "max_allocated_storage must be greater than allocated_storage so storage autoscaling is enabled."
  }
}

variable "storage_type" {
  description = "RDS storage type"
  type        = string
  default     = "gp2"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.storage_type)
    error_message = "storage_type must be one of gp2, gp3, io1, or io2."
  }
}

variable "multi_az" {
  description = "Whether to deploy the DB instance across multiple Availability Zones"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 0 and 35 days."
  }
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot on DB deletion"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled"
  type        = bool
  default     = false
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "database_name" {
  description = "Initial database name shared by the database-backed services"
  type        = string
  default     = "petclinic"
}

variable "master_username" {
  description = "RDS master username"
  type        = string
  default     = "petclinic"
}

variable "master_password_length" {
  description = "Generated RDS master password length"
  type        = number
  default     = 20

  validation {
    condition     = var.master_password_length >= 16
    error_message = "master_password_length must be at least 16 characters."
  }
}

variable "apply_immediately" {
  description = "Whether RDS modifications are applied immediately"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
