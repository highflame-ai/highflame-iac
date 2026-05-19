################################################## StorageClass
output "storageclass_name" {
  description = "StorageClass Name"
  value       = var.enable_storageclass ? module.storageclass[0].storageclass_name : null
}

output "storageclass_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_storageclass ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> storageclass" : null
}