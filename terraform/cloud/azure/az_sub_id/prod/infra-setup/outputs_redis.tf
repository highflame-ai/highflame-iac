output "redis_server_id" {
  description = "redis server id"
  value       = var.enable_redis ? module.redis[0].redis_server_id : null
}

output "redis_host" {
  description = "redis host"
  value       = var.enable_redis ? module.redis[0].redis_host : null
}

output "redis_privatelink" {
  description = "redis privatelink"
  value       = var.enable_redis ? module.redis[0].redis_privatelink : null
}

output "redis_private_ip" {
  description = "redis private ip"
  value       = var.enable_redis ? module.redis[0].redis_private_ip : null
}

output "redis_port" {
  description = "redis port"
  value       = var.enable_redis ? module.redis[0].redis_port : null
}

output "redis_ssl_port" {
  description = "redis ssl port"
  value       = var.enable_redis ? module.redis[0].redis_ssl_port : null
}

output "redis_primary_access_key" {
  description = "redis primary access key"
  sensitive   = true
  value       = var.enable_redis ? module.redis[0].redis_primary_access_key : null
}

output "redis_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_redis ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> redis" : null
}