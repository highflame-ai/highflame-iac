output "postgres_server" {
  description = "Postgres Server"
  value       = var.enable_postgres ? module.postgres[0].postgres_server : null
}

output "postgres_host" {
  description = "Postgres Host"
  value       = var.enable_postgres ? module.postgres[0].db_host : null
}

output "postgres_port" {
  description = "Postgres Port"
  value       = var.enable_postgres ? module.postgres[0].db_port : null
}

output "postgres_db_name" {
  description = "Database Name"
  value       = var.enable_postgres ? module.postgres[0].db_name : null
}

output "postgres_db_user" {
  description = "Database Username"
  value       = var.enable_postgres ? module.postgres[0].db_user : null
}

output "postgres_db_pass" {
  description = "Database Password"
  value       = var.enable_postgres ? module.postgres[0].db_pass : null
  sensitive   = true
}

output "postgres_db_javelin_customers_pass" {
  description = "Database User javelin_customers Password"
  value       = var.enable_postgres ? module.postgres[0].db_javelin_customers_pass : null
  sensitive   = true
}

output "postgres_db_javelin_admins_pass" {
  description = "Database User javelin_admins Password"
  value       = var.enable_postgres ? module.postgres[0].db_javelin_admins_pass : null
  sensitive   = true
}

output "postgres_secret_name" {
  description = "Database Password Secret Name"
  value       = var.enable_postgres ? module.postgres[0].secret_name : null
}

output "postgres_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_postgres ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> postgres" : null
}