output "postgres_deps_identity_name" {
  description = "postgres identity name"
  value       = var.enable_postgres_deps ? module.postgres_deps[0].postgres_identity_name : null
}

output "postgres_deps_identity_id" {
  description = "postgres identity id"
  value       = var.enable_postgres_deps ? module.postgres_deps[0].postgres_identity_id : null
}

output "postgres_deps_private_dns_zone_name" {
  description = "postgres private dns zone name"
  value       = var.enable_postgres_deps ? module.postgres_deps[0].postgres_private_dns_zone_name : null
}

output "postgres_deps_private_dns_zone_id" {
  description = "postgres private dns zone id"
  value       = var.enable_postgres_deps ? module.postgres_deps[0].postgres_private_dns_zone_id : null
}

output "postgres_deps_keyvault_name" {
  description = "postgres keyvault name"
  value       = var.enable_postgres_deps ? module.postgres_deps[0].postgres_keyvault_name : null
}

output "postgres_deps_keyvault_id" {
  description = "postgres keyvault id"
  value       = var.enable_postgres_deps ? module.postgres_deps[0].postgres_keyvault_id : null
}

output "postgres_deps_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_postgres_deps ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> postgres_deps" : null
}