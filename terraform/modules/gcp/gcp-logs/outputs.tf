output "gcp_log_bucket_id" {
  description = "GCP Log Bucket ID"
  value       = google_logging_project_bucket_config.log_bucket.bucket_id
}

output "gcp_log_sink" {
  description = "GCP Log Sink Name"
  value       = google_logging_project_sink.log_sink.name
}