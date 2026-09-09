output "traffic_manager_profile_id" {
  description = "Traffic Manager profile ID"
  value       = var.enable_traffic_manager ? module.traffic_manager[0].traffic_manager_profile_id : null
}

output "traffic_manager_domain" {
  description = "Traffic Manager domain"
  value       = var.enable_traffic_manager ? module.traffic_manager[0].traffic_manager_domain : null
}

output "traffic_manager_external_endpoint_id" {
  description = "Traffic Manager external endpoint ID"
  value       = var.enable_traffic_manager ? module.traffic_manager[0].traffic_manager_external_endpoint_id : null
}

output "traffic_manager_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_traffic_manager ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> traffic_manager" : null
}