output "gcp_security_policy_name" {
  description = "Security policy name"
  value       = var.enable_security_policies ? module.security_policies[0].gcp_security_policy_name : null
}

output "gcp_security_policy_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_security_policies ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> security_policies" : null
}