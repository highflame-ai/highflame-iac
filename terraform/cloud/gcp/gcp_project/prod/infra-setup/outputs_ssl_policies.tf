output "gcp_ssl_policy_name" {
  description = "SSL policy name"
  value       = var.enable_ssl_policies ? module.ssl_policies[0].gcp_ssl_policy_name : null
}

output "gcp_ssl_policy_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_ssl_policies ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ssl_policies" : null
}