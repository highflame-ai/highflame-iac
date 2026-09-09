output "aurora_postgres_secondary_cluster_arn" {
  description = "Aurora cluster ARN"
  value       = var.enable_aurora_postgres_secondary ? module.aurora_postgres_secondary[0].aurora_cluster_arn : null
}

output "aurora_postgres_secondary_host" {
  description = "Aurora Host"
  value       = var.enable_aurora_postgres_secondary ? module.aurora_postgres_secondary[0].db_host : null
}

output "aurora_postgres_secondary_port" {
  description = "Aurora Port"
  value       = var.enable_aurora_postgres_secondary ? module.aurora_postgres_secondary[0].db_port : null
}

output "aurora_postgres_secondary_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_aurora_postgres_secondary ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> aurora_postgres_secondary" : null
}