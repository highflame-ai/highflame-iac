output "redis_host" {
  description = "Redis Host"
  value       = google_redis_instance.redis_instance.host
}

output "redis_port" {
  description = "Redis Port"
  value       = google_redis_instance.redis_instance.port
}

output "redis_pass" {
  description = "Redis Password"
  value       = google_redis_instance.redis_instance.auth_string
  sensitive   = true
}

output "redis_reserved_ip_range" {
  description = "Redis Reserved IP Range"
  value       = google_redis_instance.redis_instance.reserved_ip_range
}

output "redis_secret_name" {
  description = "Redis Password Secret Name"
  value       = google_secret_manager_secret.redis_secret.secret_id
}