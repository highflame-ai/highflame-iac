output "backend_bucket_name" {
  description = "Statefile storage location"
  value       = aws_s3_bucket.backend.0.id
}

output "backend_bucket_zzzzzz" {
  description = "Separation in the output"
  value       = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> backend_bucket"
}