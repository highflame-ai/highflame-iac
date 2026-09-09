output "global_accelerator_endpoint_group_arn" {
  description = "Global Accelerator Endpoint Group arn"
  value       = var.enable_global_accelerator_endpoint ? module.global_accelerator_endpoint[0].global_accelerator_endpoint_group_arn : null
}

output "global_accelerator_endpoint_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_global_accelerator_endpoint ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> global_accelerator_endpoint" : null
}