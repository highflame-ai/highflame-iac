################################################## Helm_Chart_fluent_bit
output "fluent_bit_name" {
  description = "Helm Chart Name"
  value       = var.enable_fluent_bit ? module.fluent_bit[0].name : null
}

output "fluent_bit_namespace" {
  description = "Helm Chart Namespace"
  value       = var.enable_fluent_bit ? module.fluent_bit[0].namespace : null
}

output "fluent_bit_repository" {
  description = "Helm Chart Repository"
  value       = var.enable_fluent_bit ? module.fluent_bit[0].repository : null
}

output "fluent_bit_chart" {
  description = "Helm chart Name"
  value       = var.enable_fluent_bit ? module.fluent_bit[0].chart : null
}

output "fluent_bit_version" {
  description = "Helm Chart Version"
  value       = var.enable_fluent_bit ? module.fluent_bit[0].version : null
}

output "fluent_bit_status" {
  description = "Helm Chart Deployment Status"
  value       = var.enable_fluent_bit ? module.fluent_bit[0].status : null
}

output "fluent_bit_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_fluent_bit ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fluent_bit" : null
}