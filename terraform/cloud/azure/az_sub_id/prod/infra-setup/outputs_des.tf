output "des_keyvault_name" {
  description = "DES keyvault name"
  value       = var.enable_des ? module.des[0].des_keyvault_name : null
}

output "des_keyvault_id" {
  description = "DES keyvault id"
  value       = var.enable_des ? module.des[0].des_keyvault_id : null
}

output "des_keyvault_key_name" {
  description = "DES keyvault key name"
  value       = var.enable_des ? module.des[0].des_keyvault_key_name : null
}

output "des_keyvault_key_id" {
  description = "DES keyvault key id"
  value       = var.enable_des ? module.des[0].des_keyvault_key_id : null
}

output "des_name" {
  description = "DES name"
  value       = var.enable_des ? module.des[0].des_name : null
}

output "des_id" {
  description = "DES id"
  value       = var.enable_des ? module.des[0].des_id : null
}

output "des_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_des ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> des" : null
}