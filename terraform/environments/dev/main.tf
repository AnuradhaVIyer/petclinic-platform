module "vpc" {
  source = "../../modules/vpc"

  project             = var.project
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
}

module "eks" {
  source = "../../modules/eks"

  project             = var.project
  environment         = var.environment
  cluster_version     = var.eks_cluster_version
  subnet_ids          = module.vpc.public_subnet_ids
  cluster_sg_id       = module.vpc.eks_cluster_sg_id
  node_sg_id          = module.vpc.eks_node_sg_id
  node_instance_types = var.eks_node_instance_types
  node_ami_type       = var.eks_node_ami_type
  node_min_size       = var.eks_node_min_size
  node_max_size       = var.eks_node_max_size
  node_desired_size   = var.eks_node_desired_size
  node_disk_size      = var.eks_node_disk_size
}

module "ecr" {
  source = "../../modules/ecr"

  project       = var.project
  environment   = var.environment
  service_names = var.service_names
}

module "rds" {
  source = "../../modules/rds"

  project                 = var.project
  environment             = var.environment
  subnet_ids              = module.vpc.public_subnet_ids
  security_group_id       = module.vpc.rds_sg_id
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  max_allocated_storage   = var.rds_max_allocated_storage
  multi_az                = false
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = var.rds_deletion_protection
}

/*module "dns" {
  source = "../../modules/dns"

  project           = var.project
  environment       = var.environment
  domain_name       = var.domain_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  create_app_record = var.dns_create_app_record
  alb_name          = var.dns_alb_name
}*/
