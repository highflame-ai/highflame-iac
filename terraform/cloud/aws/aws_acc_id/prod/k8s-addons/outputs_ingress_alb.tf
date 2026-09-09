################################################## Helm_Chart_ingress_alb
output "alb_ingress_iam_role_arn" {
  description = "IAM Role for ALB Ingress Controller"
  value       = var.enable_ingress_alb ? module.ingress_alb[0].alb_ingress_iam_role_arn : null
}

output "ingress_alb_name" {
  description = "Helm Chart Name"
  value       = var.enable_ingress_alb ? module.ingress_alb[0].name : null
}

output "ingress_alb_namespace" {
  description = "Helm Chart Namespace"
  value       = var.enable_ingress_alb ? module.ingress_alb[0].namespace : null
}

output "ingress_alb_repository" {
  description = "Helm Chart Repository"
  value       = var.enable_ingress_alb ? module.ingress_alb[0].repository : null
}

output "ingress_alb_chart" {
  description = "Helm chart Name"
  value       = var.enable_ingress_alb ? module.ingress_alb[0].chart : null
}

output "ingress_alb_version" {
  description = "Helm Chart Version"
  value       = var.enable_ingress_alb ? module.ingress_alb[0].version : null
}

output "ingress_alb_status" {
  description = "Helm Chart Deployment Status"
  value       = var.enable_ingress_alb ? module.ingress_alb[0].status : null
}

output "ingress_alb_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_ingress_alb ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ingress_alb" : null
}