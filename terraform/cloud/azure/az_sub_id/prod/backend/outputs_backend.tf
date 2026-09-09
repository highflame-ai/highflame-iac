################################################## Backend
output "backend_resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.resource_grp[0].name
}

output "backend_storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.backend[0].name
}

output "backend_storage_container_name" {
  description = "Storage container name"
  value       = azurerm_storage_container.backend[0].name
}

output "backend_bucket_zzzzzz" {
  description = "Separation in the output"
  value       = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> backend"
}