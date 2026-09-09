output "gke_ingress_ip" {
  description = "GKE Ingress IP"
  value       = var.enable_gke ? module.gke[0].gke_ingress_ip : null
}

output "gke_ingress_ip_name" {
  description = "GKE Ingress IP Name"
  value       = var.enable_gke ? module.gke[0].gke_ingress_ip_name : null
}

output "gke_cluster_name" {
  description = "GKE Cluster Name"
  value       = var.enable_gke ? module.gke[0].gke_cluster_name : null
}

output "gke_master_version" {
  description = "GKE Cluster version"
  value       = var.enable_gke ? module.gke[0].gke_master_version : null
}

output "gke_cluster_location" {
  description = "GKE Cluster Location"
  value       = var.enable_gke ? module.gke[0].gke_cluster_location : null
}

output "gke_cluster_id" {
  description = "GKE Cluster ID"
  value       = var.enable_gke ? module.gke[0].gke_cluster_id : null
}

output "gke_role_name" {
  description = "GKE Role for SA"
  value       = var.enable_gke ? module.gke[0].gke_role_name : null
}

output "gke_service_account_id" {
  description = "GKE SA ID"
  value       = var.enable_gke ? module.gke[0].gke_service_account_id : null
}

output "gke_service_account_email" {
  description = "GKE SA Email"
  value       = var.enable_gke ? module.gke[0].gke_service_account_email : null
}

output "gke_cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = var.enable_gke ? module.gke[0].gke_cluster_endpoint : null
}

output "gke_cluster_master_auth" {
  description = "GKE cluster master auth"
  value       = var.enable_gke ? module.gke[0].gke_cluster_master_auth : null
  sensitive   = true
}

output "gke_kms_keyring_name" {
  description = "GKE keyring name for encryption"
  value       = var.enable_gke ? module.gke[0].gke_kms_keyring_name : null
}

output "gke_kms_key_name" {
  description = "GKE key name for encryption"
  value       = var.enable_gke ? module.gke[0].gke_kms_key_name : null
}

output "gke_kms_key_id" {
  description = "GKE key id for encryption"
  value       = var.enable_gke ? module.gke[0].gke_kms_key_id : null
}

output "gke_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_gke ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> gke" : null
}