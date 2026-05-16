locals {
  name_prefix   = "${var.project}-${var.environment}"
  db_identifier = "${local.name_prefix}-mysql"
  common_tags = merge(
    var.tags,
    {
      Component   = "database"
      Environment = var.environment
    }
  )
}

resource "random_password" "master" {
  length           = var.master_password_length
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${var.project}/${var.environment}/rds-credentials"
  description = "RDS master credentials for ${local.db_identifier}"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
  })
}

resource "aws_db_subnet_group" "main" {
  name        = "${local.name_prefix}-rds-subnet-group"
  description = "Subnet group for ${local.db_identifier}"
  subnet_ids  = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-subnet-group"
  })
}

resource "aws_db_parameter_group" "mysql" {
  name        = "${local.name_prefix}-mysql80"
  family      = "mysql8.0"
  description = "MySQL 8.0 parameters for ${local.db_identifier}"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-mysql80"
  })
}

resource "aws_db_instance" "mysql" {
  identifier = local.db_identifier

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  db_name  = var.database_name
  username = var.master_username
  password = random_password.master.result
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]
  parameter_group_name   = aws_db_parameter_group.mysql.name
  publicly_accessible    = false

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = (
    var.skip_final_snapshot ? null : "${local.db_identifier}-final-snapshot"
  )

  apply_immediately = var.apply_immediately

  tags = merge(local.common_tags, {
    Name = local.db_identifier
  })
}
