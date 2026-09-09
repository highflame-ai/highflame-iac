output "postgres_secondary_server_id" {
  description = "postgres server id"
  value       = var.enable_postgres_secondary ? module.postgres_secondary[0].postgres_server_id : null
}

output "postgres_secondary_host" {
  description = "postgres host"
  value       = var.enable_postgres_secondary ? module.postgres_secondary[0].postgres_host : null
}

output "postgres_secondary_private_ip" {
  description = "postgres secondary private ip"
  value       = var.enable_postgres_secondary ? module.postgres_secondary[0].postgres_private_ip : null
}

output "postgres_secondary_port" {
  description = "postgres port"
  value       = var.enable_postgres_secondary ? module.postgres_secondary[0].postgres_port : null
}

output "postgres_secondary_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_postgres_secondary ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> postgres_secondary" : null
}