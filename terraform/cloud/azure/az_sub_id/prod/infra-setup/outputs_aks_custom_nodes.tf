output "aks_custom_nodepool_id" {
  description = "AKS custom nodepool id"
  value       = var.enable_aks_custom_nodepool ? module.aks_custom_nodepool[0].aks_nodepool_id : null
}

output "aks_custom_nodepool_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_aks_custom_nodepool ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> aks_custom_nodepool" : null
}