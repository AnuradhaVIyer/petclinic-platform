output "endpoint" {
  description = "RDS endpoint hostname"
  value       = aws_db_instance.mysql.address
}

output "port" {
  description = "RDS port"
  value       = aws_db_instance.mysql.port
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.mysql.identifier
}

output "secret_arn" {
  description = "Secrets Manager secret ARN for RDS credentials"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}

output "secret_arns" {
  description = "Map of RDS-related Secrets Manager secret ARNs"
  value = {
    rds_credentials = aws_secretsmanager_secret.rds_credentials.arn
  }
}

output "secret_name" {
  description = "Secrets Manager secret name for RDS credentials"
  value       = aws_secretsmanager_secret.rds_credentials.name
}

output "database_name" {
  description = "Shared database name"
  value       = aws_db_instance.mysql.db_name
}

output "jdbc_url" {
  description = "JDBC URL for the shared petclinic database"
  value       = "jdbc:mysql://${aws_db_instance.mysql.address}:${aws_db_instance.mysql.port}/${aws_db_instance.mysql.db_name}"
}
