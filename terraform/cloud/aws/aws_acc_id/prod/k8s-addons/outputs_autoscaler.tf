################################################## Auto_Scaler
output "auto_scaler_iam_policy" {
  description = "IAM Policy for cluster autoscaler service"
  value       = var.enable_autoscaler ? module.autoscaler[0].auto_scaler_iam_policy : null
}

output "auto_scaler_iam_role" {
  description = "IAM Role for cluster autoscaler service"
  value       = var.enable_autoscaler ? module.autoscaler[0].auto_scaler_iam_role : null
}

output "auto_scaler_name" {
  description = "Helm Chart Name"
  value       = var.enable_autoscaler ? module.autoscaler[0].name : null
}

output "auto_scaler_namespace" {
  description = "Helm Chart Namespace"
  value       = var.enable_autoscaler ? module.autoscaler[0].namespace : null
}

output "auto_scaler_repository" {
  description = "Helm Chart Repository"
  value       = var.enable_autoscaler ? module.autoscaler[0].repository : null
}

output "auto_scaler_chart" {
  description = "Helm chart Name"
  value       = var.enable_autoscaler ? module.autoscaler[0].chart : null
}

output "auto_scaler_version" {
  description = "Helm Chart Version"
  value       = var.enable_autoscaler ? module.autoscaler[0].version : null
}

output "auto_scaler_status" {
  description = "Helm Chart Deployment Status"
  value       = var.enable_autoscaler ? module.autoscaler[0].status : null
}

output "auto_scaler_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_autoscaler ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> auto_scaler" : null
}