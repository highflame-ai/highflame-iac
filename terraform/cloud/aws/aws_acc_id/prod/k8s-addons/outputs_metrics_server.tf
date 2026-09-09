################################################## Helm_Chart_metrics_server
output "metrics_server_name" {
  description = "Helm Chart Name"
  value       = var.enable_metrics_server ? module.metrics_server[0].name : null
}

output "metrics_server_namespace" {
  description = "Helm Chart Namespace"
  value       = var.enable_metrics_server ? module.metrics_server[0].namespace : null
}

output "metrics_server_repository" {
  description = "Helm Chart Repository"
  value       = var.enable_metrics_server ? module.metrics_server[0].repository : null
}

output "metrics_server_chart" {
  description = "Helm chart Name"
  value       = var.enable_metrics_server ? module.metrics_server[0].chart : null
}

output "metrics_server_version" {
  description = "Helm Chart Version"
  value       = var.enable_metrics_server ? module.metrics_server[0].version : null
}

output "metrics_server_status" {
  description = "Helm Chart Deployment Status"
  value       = var.enable_metrics_server ? module.metrics_server[0].status : null
}

output "metrics_server_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_metrics_server ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> metrics_server" : null
}