################################################## Docker_Secret
output "registry_secret_name" {
  description = "Docker Registry Secret Name"
  value       = var.enable_docker_secret ? module.docker_secret[0].registry_secret : null
}

output "registry_secret_namespace_list" {
  description = "Docker Registry Secret Available Namespace"
  value       = var.enable_docker_secret ? module.docker_secret[0].namespace_list : null
}

output "registry_secret_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_docker_secret ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> registry_secret" : null
}