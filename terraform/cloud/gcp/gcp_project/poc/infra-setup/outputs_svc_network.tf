output "svc_networking_ip_range" {
  description = "Private networking IP range"
  value       = var.enable_svc_network ? module.svc_network[0].svc_networking_ip_range : null
}

output "svc_networking_name" {
  description = "Private networking name"
  value       = var.enable_svc_network ? module.svc_network[0].svc_networking_name : null
}

output "svc_networking_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_svc_network ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> vpc" : null
}