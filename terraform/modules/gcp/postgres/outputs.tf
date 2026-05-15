# output "postgres_kms_keyring" {
#   description = "Keyring for postgres disk encryption"
#   value       = google_kms_key_ring.postgres_keyring.id
# }

# output "postgres_kms_crypto_key" {
#   description = "Crypto key for postgres disk encryption"
#   value       = google_kms_crypto_key.postgres_key.id
# }

output "postgres_server" {
  description = "Postgres Server"
  value       = google_sql_database_instance.postgres_instance.id
}

output "db_host" {
  description = "Postgres Host"
  value       = google_sql_database_instance.postgres_instance.private_ip_address
}

# output "db_public_host" {
#   description = "Postgres Public IP"
#   value       = google_sql_database_instance.postgres_instance.public_ip_address
# }

output "db_port" {
  description = "Postgres Port"
  value       = "5432"
}

output "db_name" {
  description = "Database Name"
  value       = var.db_name
}

output "db_user" {
  description = "Database Username"
  value       = var.db_user
}

output "db_pass" {
  description = "Database Password"
  value       = random_password.db_password.result
  sensitive   = true
}

output "db_javelin_customers_pass" {
  description = "Database User javelin_customers Password"
  value       = random_password.javelin_customers_password.result
  sensitive   = true
}

output "db_javelin_admins_pass" {
  description = "Database User javelin_admins Password"
  value       = random_password.javelin_admins_password.result
  sensitive   = true
}

output "secret_name" {
  description = "Database Password Secret Name"
  value       = google_secret_manager_secret.postgres_secret.secret_id
}