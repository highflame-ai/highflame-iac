output "gke_ingress_ip" {
  description = "GKE Ingress IP"
  value       = google_compute_global_address.ingress_static_ip.address
}

output "gke_ingress_ip_name" {
  description = "GKE Ingress IP Name"
  value       = google_compute_global_address.ingress_static_ip.name
}

output "gke_cluster_name" {
  description = "GKE Cluster Name"
  value       = google_container_cluster.gke_cluster.name
}

output "gke_master_version" {
  description = "GKE Cluster version"
  value       = google_container_cluster.gke_cluster.master_version
}

output "gke_cluster_location" {
  description = "GKE Cluster Location"
  value       = google_container_cluster.gke_cluster.location
}

output "gke_cluster_id" {
  description = "GKE Cluster ID"
  value       = google_container_cluster.gke_cluster.id
}

output "gke_role_name" {
  description = "GKE Role for SA"
  value       = google_project_iam_custom_role.gke_role.name
}

output "gke_service_account_id" {
  description = "GKE SA ID"
  value       = google_service_account.gke_sa.account_id
}

output "gke_service_account_email" {
  description = "GKE SA Email"
  value       = google_service_account.gke_sa.email
}

output "gke_cluster_endpoint" {
  description = "GKE Cluster endpoint"
  value       = google_container_cluster.gke_cluster.endpoint
}

output "gke_cluster_master_auth" {
  description = "GKE cluster master auth"
  value       = google_container_cluster.gke_cluster.master_auth.0
  sensitive   = true
}

output "gke_kms_keyring_name" {
  description = "GKE keyring name for encryption"
  value       = google_kms_key_ring.gke_keyring.name
}

output "gke_kms_key_name" {
  description = "GKE key name for encryption"
  value       = google_kms_crypto_key.gke_key.name
}

output "gke_kms_key_id" {
  description = "GKE key id for encryption"
  value       = google_kms_crypto_key.gke_key.id
}