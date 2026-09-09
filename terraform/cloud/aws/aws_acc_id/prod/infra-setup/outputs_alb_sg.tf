# ################################################## ALB sg
output "alb_fe_security_group_id" {
  description = "ALB FE Security Group ID"
  value       = var.enable_alb_sg ? module.alb_sg[0].alb_fe_security_group_id : null
}

output "alb_fe_security_group_name" {
  description = "ALB FE Security Group Name"
  value       = var.enable_alb_sg ? module.alb_sg[0].alb_fe_security_group_name : null
}

output "alb_fe_security_group_arn" {
  description = "ALB FE Security Group arn"
  value       = var.enable_alb_sg ? module.alb_sg[0].alb_fe_security_group_arn : null
}

output "alb_be_security_group_id" {
  description = "ALB BE Security Group ID"
  value       = var.enable_alb_sg ? module.alb_sg[0].alb_be_security_group_id : null
}

output "alb_be_security_group_name" {
  description = "ALB BE Security Group Name"
  value       = var.enable_alb_sg ? module.alb_sg[0].alb_be_security_group_name : null
}

output "alb_be_security_group_arn" {
  description = "ALB BE Security Group arn"
  value       = var.enable_alb_sg ? module.alb_sg[0].alb_be_security_group_arn : null
}

output "alb_security_group_ids" {
  description = "ALB FE and BE Security Group IDs"
  value       = var.enable_alb_sg ? module.alb_sg[0].alb_security_group_ids : null
}

output "alb_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_alb_sg ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> alb" : null
}