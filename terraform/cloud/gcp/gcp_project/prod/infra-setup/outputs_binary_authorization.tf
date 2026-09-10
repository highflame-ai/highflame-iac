output "binary_authorization_policy" {
  description = "Default binary authorization policy"
  value       = var.enable_binary_authorization ? module.binary_authorization[0].binary_authorization_policy : null
}

output "binary_authorization_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_binary_authorization ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> binary_authorization" : null
}