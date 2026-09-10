output "postgres_primary_server_id" {
  description = "postgres server id"
  value       = var.enable_postgres_primary ? module.postgres_primary[0].postgres_server_id : null
}

output "postgres_primary_host" {
  description = "postgres host"
  value       = var.enable_postgres_primary ? module.postgres_primary[0].postgres_host : null
}

output "postgres_primary_private_ip" {
  description = "postgres primary private ip"
  value       = var.enable_postgres_primary ? module.postgres_primary[0].postgres_private_ip : null
}

output "postgres_primary_port" {
  description = "postgres port"
  value       = var.enable_postgres_primary ? module.postgres_primary[0].postgres_port : null
}

output "postgres_primary_db_name" {
  description = "Database Name"
  value       = var.enable_postgres_primary ? module.postgres_primary[0].postgres_db_name : null
}

output "postgres_primary_db_user" {
  description = "Database Username"
  value       = var.enable_postgres_primary ? module.postgres_primary[0].postgres_db_user : null
}

output "postgres_primary_db_pass" {
  description = "Database Password"
  value       = var.enable_postgres_primary ? module.postgres_primary[0].postgres_db_pass : null
  sensitive   = true
}

output "postgres_primary_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_postgres_primary ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> postgres_primary" : null
}