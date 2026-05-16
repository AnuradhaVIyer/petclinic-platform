variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "petclinic"
}

# --- VPC ---

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

# --- EKS ---

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "eks_node_instance_types" {
  description = "Instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t4g.small"]
}

variable "eks_node_ami_type" {
  description = "AMI type for EKS nodes"
  type        = string
  default     = "AL2_ARM_64"
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 4
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 2
}

variable "eks_node_disk_size" {
  description = "Disk size in GB for EKS nodes"
  type        = number
  default     = 20
}

# --- ECR ---

variable "service_names" {
  description = "Petclinic service names for ECR repositories"
  type        = list(string)
  default = [
    "config-server",
    "discovery-server",
    "api-gateway",
    "customers-service",
    "visits-service",
    "vets-service",
    "genai-service",
    "admin-server",
  ]
}

# --- RDS ---

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "rds_allocated_storage" {
  description = "Initial RDS storage in GB"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum autoscaled RDS storage in GB"
  type        = number
  default     = 100
}

variable "rds_deletion_protection" {
  description = "Whether RDS deletion protection is enabled"
  type        = bool
  default     = false
}
