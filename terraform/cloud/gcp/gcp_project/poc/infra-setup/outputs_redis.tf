output "redis_host" {
  description = "Redis Host"
  value       = var.enable_redis ? module.redis[0].redis_host : null
}

output "redis_port" {
  description = "Redis Port"
  value       = var.enable_redis ? module.redis[0].redis_port : null
}

output "redis_pass" {
  description = "Redis Password"
  value       = var.enable_redis ? module.redis[0].redis_pass : null
  sensitive   = true
}

output "redis_reserved_ip_range" {
  description = "Redis Reserved IP Range"
  value       = var.enable_redis ? module.redis[0].redis_reserved_ip_range : null
}

output "redis_secret_name" {
  description = "Redis Reserved IP Range"
  value       = var.enable_redis ? module.redis[0].redis_secret_name : null
}

output "redis_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_redis ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> redis" : null
}