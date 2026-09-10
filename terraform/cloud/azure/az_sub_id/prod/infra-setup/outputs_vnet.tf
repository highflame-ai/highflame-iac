output "vnet_name" {
  description = "Vnet name"
  value       = var.enable_vnet ? module.vnet[0].vnet_name : null
}

output "vnet_id" {
  description = "Vnet id"
  value       = var.enable_vnet ? module.vnet[0].vnet_id : null
}

output "private_subnet_name" {
  description = "Private subnet name"
  value       = var.enable_vnet ? module.vnet[0].private_subnet_name : null
}

output "private_subnet_id" {
  description = "Private subnet id"
  value       = var.enable_vnet ? module.vnet[0].private_subnet_id : null
}

output "private_subnet_cidr" {
  description = "Private subnet cidr"
  value       = var.enable_vnet ? module.vnet[0].private_subnet_cidr : null
}

# output "private_delegate_subnet_name" {
#   description = "Private delegate subnet name"
#   value       = var.enable_vnet ? module.vnet[0].private_delegate_subnet_name : null
# }

# output "private_delegate_subnet_id" {
#   description = "Private delegate subnet id"
#   value       = var.enable_vnet ? module.vnet[0].private_delegate_subnet_id : null
# }

# output "private_delegate_subnet_cidr" {
#   description = "Private delegate subnet cidr"
#   value       = var.enable_vnet ? module.vnet[0].private_delegate_subnet_cidr : null
# }

output "appgw_subnet_name" {
  description = "App GW subnet name"
  value       = var.enable_vnet ? module.vnet[0].appgw_subnet_name : null
}

output "appgw_subnet_id" {
  description = "App GW subnet id"
  value       = var.enable_vnet ? module.vnet[0].appgw_subnet_id : null
}

output "appgw_subnet_cidr" {
  description = "App GW subnet cidr"
  value       = var.enable_vnet ? module.vnet[0].appgw_subnet_cidr : null
}

output "public_subnet_name" {
  description = "Public subnet name"
  value       = var.enable_vnet ? module.vnet[0].public_subnet_name : null
}

output "public_subnet_id" {
  description = "Public subnet id"
  value       = var.enable_vnet ? module.vnet[0].public_subnet_id : null
}

output "public_subnet_cidr" {
  description = "Public subnet cidr"
  value       = var.enable_vnet ? module.vnet[0].public_subnet_cidr : null
}

output "nat_gateway_name" {
  description = "NAT name"
  value       = var.enable_vnet ? module.vnet[0].nat_gateway_name : null
}

output "nat_gateway_id" {
  description = "NAT id"
  value       = var.enable_vnet ? module.vnet[0].nat_gateway_id : null
}

output "nat_gateway_ip" {
  description = "NAT ip"
  value       = var.enable_vnet ? module.vnet[0].nat_gateway_ip : null
}

output "vnet_nsg_name" {
  description = "vnet nsg name"
  value       = var.enable_vnet ? module.vnet[0].vnet_nsg_name : null
}

output "vnet_nsg_id" {
  description = "vnet nsg id"
  value       = var.enable_vnet ? module.vnet[0].vnet_nsg_id : null
}

output "vnet_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_vnet ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> vnet" : null
}