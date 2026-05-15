# ################################################## S3
output "s3_bucket_arn" {
  description = "Javelin S3 Bucket arn"
  value       = module.s3.bucket_arn
}

output "s3_bucket_name" {
  description = "Storage Bucket name"
  value       = module.s3.bucket_name
}

output "s3_bucket_zzzzzz" {
  description = "Separation in the output"
  value       = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> s3_bucket"
}