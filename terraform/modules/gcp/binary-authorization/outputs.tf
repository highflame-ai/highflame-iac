output "binary_authorization_policy" {
  description = "Default binary authorization policy"
  value       = google_binary_authorization_policy.policy.id
}