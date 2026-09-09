output "aurora_postgres_deps_cluster_pramas_grp" {
  description = "Aurora Cluster Parameter Group"
  value       = var.enable_aurora_postgres_deps ? module.aurora_postgres_deps[0].aurora_cluster_pramas_grp : null
}

output "aurora_postgres_deps_db_pramas_grp" {
  description = "Aurora DB Parameter Group"
  value       = var.enable_aurora_postgres_deps ? module.aurora_postgres_deps[0].aurora_db_pramas_grp : null
}

output "aurora_postgres_deps_subnet_grp" {
  description = "Aurora Subnet Group"
  value       = var.enable_aurora_postgres_deps ? module.aurora_postgres_deps[0].aurora_subnet_grp : null
}

output "aurora_postgres_deps_kms_key_arn" {
  description = "Aurora KMS Key ARN"
  value       = var.enable_aurora_postgres_deps ? module.aurora_postgres_deps[0].aurora_kms_key_arn : null
}

output "aurora_postgres_deps_security_grp" {
  description = "Aurora Security Group"
  value       = var.enable_aurora_postgres_deps ? module.aurora_postgres_deps[0].aurora_security_grp : null
}

output "aurora_postgres_deps_secret_name" {
  description = "Aurora Password Secret Name"
  value       = var.enable_aurora_postgres_deps ? module.aurora_postgres_deps[0].aurora_secret_name : null
}

output "aurora_postgres_deps_secret_arn" {
  description = "Aurora Password Secret ARN"
  value       = var.enable_aurora_postgres_deps ? module.aurora_postgres_deps[0].aurora_secret_arn : null
}

output "aurora_postgres_deps_postgres_deps_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_aurora_postgres_deps ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> aurora_postgres_deps" : null
}