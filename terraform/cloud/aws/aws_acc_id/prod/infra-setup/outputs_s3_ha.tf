# ################################################## S3
output "ha_s3_bucket_arn" {
  description = "HA Javelin S3 Bucket arn"
  value       = module.ha_s3.bucket_arn
}

output "ha_s3_bucket_name" {
  description = "HA Storage Bucket name"
  value       = module.ha_s3.bucket_name
}

output "ha_s3_bucket_zzzzzz" {
  description = "HA Separation in the output"
  value       = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> s3_bucket"
}