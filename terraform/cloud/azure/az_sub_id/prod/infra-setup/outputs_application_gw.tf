output "application_gw_ip_address" {
  description = "application gateway ip address"
  value       = var.enable_application_gw ? module.application_gw[0].appgw_ip_address : null
}

output "application_gw_identity_id" {
  description = "application gateway user identity"
  value       = var.enable_application_gw ? module.application_gw[0].appgw_identity_id : null
}

output "application_gw_name" {
  description = "application gateway name"
  value       = var.enable_application_gw ? module.application_gw[0].appgw_name : null
}

output "application_gw_id" {
  description = "application gateway id"
  value       = var.enable_application_gw ? module.application_gw[0].appgw_id : null
}

output "application_gw_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_application_gw ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> application_gw" : null
}