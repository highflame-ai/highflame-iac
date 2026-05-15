output "gcp_security_policy_name" {
  description = "Security policy name"
  value       = google_compute_security_policy.security_policy.name
}