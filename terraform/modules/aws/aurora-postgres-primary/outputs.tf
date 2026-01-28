output "aurora_global_cluster_identifier" {
  description = "Aurora Global Cluster ID"
  value       = aws_rds_global_cluster.aurora_global.id
}

output "aurora_global_arn" {
  description = "Aurora Global ARN"
  value       = aws_rds_global_cluster.aurora_global.arn
}

output "aurora_cluster_arn" {
  description = "Aurora Cluster ARN"
  value       = aws_rds_cluster.aurora_global.arn
}

output "aurora_global_host" {
  description = "Aurora Global Host"
  value       = aws_rds_global_cluster.aurora_global.endpoint
}

output "db_host" {
  description = "Aurora Host"
  value       = aws_rds_cluster.aurora_global.endpoint
}

output "db_port" {
  description = "Aurora Port"
  value       = aws_rds_cluster.aurora_global.port
}

output "db_name" {
  description = "Database Name"
  value       = aws_rds_global_cluster.aurora_global.database_name
}

output "db_user" {
  description = "Database Username"
  value       = aws_rds_cluster.aurora_global.master_username
}

output "db_pass" {
  description = "Database Password"
  value       = aws_rds_cluster.aurora_global.master_password
  sensitive   = true
}