output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = var.enable_aks ? module.aks[0].aks_cluster_name : null
}

output "aks_cluster_id" {
  description = "AKS cluster id"
  value       = var.enable_aks ? module.aks[0].aks_cluster_id : null
}

output "aks_log_workspace" {
  description = "AKS log workspace"
  value       = var.enable_aks ? module.aks[0].aks_log_workspace : null
}

output "aks_cluster_kubeconfig" {
  description = "AKS cluster kube config"
  value       = var.enable_aks ? module.aks[0].aks_cluster_kubeconfig : null
  sensitive   = true
}

output "aks_oidc_issuer_url" {
  description = "AKS oidc issuer url"
  value       = var.enable_aks ? module.aks[0].aks_oidc_issuer_url : null
}

output "aks_cluster_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_aks ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> aks_cluster" : null
}