output "registry_secret" {
  description = "Docker Registry Secret Name"
  value       = local.secret_name
}

output "namespace_list" {
  description = "Docker Registry Secret Available Namespace"
  value       = var.secret_namespace_list
}