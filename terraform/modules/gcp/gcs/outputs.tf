output "gcs_bucket_name" {
  description = "GCS Bucket name"
  value       = [ for f in var.create_bucket_list : f.name ]
}