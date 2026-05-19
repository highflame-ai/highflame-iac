output "gcp_ssl_policy_name" {
  description = "SSL policy name"
  value       = google_compute_ssl_policy.ssl_policy.name
}