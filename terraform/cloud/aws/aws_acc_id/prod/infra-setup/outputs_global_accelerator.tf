output "global_accelerator_arn" {
  description = "Global Accelerator arn"
  value       = var.enable_global_accelerator ? module.global_accelerator[0].global_accelerator_arn : null
}

output "global_accelerator_dns" {
  description = "Global Accelerator DNS"
  value       = var.enable_global_accelerator ? module.global_accelerator[0].global_accelerator_dns : null
}

output "global_accelerator_listener_arn" {
  description = "Global Accelerator Listener arn"
  value       = var.enable_global_accelerator ? module.global_accelerator[0].global_accelerator_listener_arn : null
}

output "global_accelerator_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_global_accelerator ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> global_accelerator" : null
}