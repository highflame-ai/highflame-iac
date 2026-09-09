output "ssl_keyvault_name" {
  description = "SSL keyvault name"
  value       = var.enable_ssl_keyvault ? module.ssl_keyvault[0].ssl_keyvault_name : null
}

output "ssl_keyvault_id" {
  description = "SSL keyvault id"
  value       = var.enable_ssl_keyvault ? module.ssl_keyvault[0].ssl_keyvault_id : null
}

output "ssl_keyvault_ssl_secret_id" {
  description = "SSL keyvault ssl secret id"
  value       = var.enable_ssl_keyvault ? module.ssl_keyvault[0].ssl_keyvault_ssl_secret_id : null
}

output "ssl_keyvault_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_ssl_keyvault ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ssl_keyvault" : null
}