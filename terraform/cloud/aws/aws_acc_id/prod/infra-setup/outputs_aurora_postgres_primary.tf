output "aurora_postgres_primary_global_cluster_identifier" {
  description = "Aurora Global Cluster ID"
  value       = var.enable_aurora_postgres_primary ? module.aurora_postgres_primary[0].aurora_global_cluster_identifier : null
}

output "aurora_postgres_primary_global_arn" {
  description = "Aurora Global ARN"
  value       = var.enable_aurora_postgres_primary ? module.aurora_postgres_primary[0].aurora_global_arn : null
}

output "aurora_postgres_primary_cluster_arn" {
  description = "Aurora Cluster ARN"
  value       = var.enable_aurora_postgres_primary ? module.aurora_postgres_primary[0].aurora_cluster_arn : null
}

output "aurora_postgres_global_host" {
  description = "Aurora Global Host"
  value       = var.enable_aurora_postgres_primary ? module.aurora_postgres_primary[0].aurora_global_host : null
}

output "aurora_postgres_primary_host" {
  description = "Aurora Host"
  value       = var.enable_aurora_postgres_primary ? module.aurora_postgres_primary[0].db_host : null
}

output "aurora_postgres_primary_port" {
  description = "Aurora Port"
  value       = var.enable_aurora_postgres_primary ? module.aurora_postgres_primary[0].db_port : null
}

output "aurora_postgres_primary_db_name" {
  description = "Database Name"
  value       = var.enable_aurora_postgres_primary ? module.aurora_postgres_primary[0].db_name : null
}

output "aurora_postgres_primary_db_user" {
  description = "Database Username"
  value       = var.enable_aurora_postgres_primary ? module.aurora_postgres_primary[0].db_user : null
}

output "aurora_postgres_primary_db_pass" {
  description = "Database Password"
  value       = var.enable_aurora_postgres_primary ? module.aurora_postgres_primary[0].db_pass : null
  sensitive   = true
}

output "aurora_postgres_primary_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_aurora_postgres_primary ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> aurora_postgres_primary" : null
}