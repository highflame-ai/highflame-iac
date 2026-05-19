output "iam_email" {
  description = "Service SA email"
  value       = google_service_account.svc_sa.email
}