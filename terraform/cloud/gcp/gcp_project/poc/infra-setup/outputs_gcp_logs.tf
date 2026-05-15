output "gcp_log_bucket_id" {
  description = "GCP Log Bucket ID"
  value       = var.enable_gcp_logs ? module.gcp_logs[0].gcp_log_bucket_id : null
}

output "gcp_log_sink" {
  description = "GCP Log Sink Name"
  value       = var.enable_gcp_logs ? module.gcp_logs[0].gcp_log_sink : null
}

output "gcp_log_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_gcp_logs ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> gcp_log" : null
}