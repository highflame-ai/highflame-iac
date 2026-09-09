output "redis_cluster_host" {
  description = "Redis Cluster Host"
  value       = var.enable_redis ? module.redis_cluster[0].redis_cluster_host : null
}

output "redis_cluster_port" {
  description = "Redis Cluster Port"
  value       = var.enable_redis ? module.redis_cluster[0].redis_cluster_port : null
}

output "redis_cluster_pass" {
  description = "Redis Cluster Password"
  value       = var.enable_redis ? module.redis_cluster[0].redis_cluster_pass : null
  sensitive   = true
}

output "redis_cluster_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_redis ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> redis_cluster" : null
}