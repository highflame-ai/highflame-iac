output "cert_manager_name" {
  description = "Helm Chart Name"
  value       = var.enable_cert_manager ? module.cert_manager[0].name : null
}

output "cert_manager_namespace" {
  description = "Helm Chart Namespace"
  value       = var.enable_cert_manager ? module.cert_manager[0].namespace : null
}

output "cert_manager_repository" {
  description = "Helm Chart Repository"
  value       = var.enable_cert_manager ? module.cert_manager[0].repository : null
}

output "cert_manager_chart" {
  description = "Helm chart Name"
  value       = var.enable_cert_manager ? module.cert_manager[0].chart : null
}

output "cert_manager_version" {
  description = "Helm Chart Version"
  value       = var.enable_cert_manager ? module.cert_manager[0].version : null
}

output "cert_manager_status" {
  description = "Helm Chart Deployment Status"
  value       = var.enable_cert_manager ? module.cert_manager[0].status : null
}

output "cert_manager_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_cert_manager ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> cert_manager" : null
}