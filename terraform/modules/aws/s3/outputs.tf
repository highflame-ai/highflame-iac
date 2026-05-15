output "bucket_arn" {
  description = "S3 Bucket arn"
  value       = [ for f in aws_s3_bucket.s3_bucket : f.arn ]
}

output "bucket_name" {
  description = "S3 Bucket name"
  value       = [ for f in aws_s3_bucket.s3_bucket : f.bucket ]
}