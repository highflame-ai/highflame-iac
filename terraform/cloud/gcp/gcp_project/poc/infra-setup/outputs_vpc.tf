output "vpc_id" {
  description = "The VPC ID"
  value       = var.enable_vpc ? module.vpc[0].vpc_id : null
}

output "vpc_name" {
  description = "The VPC Name"
  value       = var.enable_vpc ? module.vpc[0].vpc_name : null
}

output "vpc_private_cidr_block" {
  description = "Private Subnet CIDR block"
  value       = var.enable_vpc ? module.vpc[0].private_cidr_block : null
}

output "vpc_public_cidr_block" {
  description = "Public Subnet CIDR block"
  value       = var.enable_vpc ? module.vpc[0].public_cidr_block : null
}

output "vpc_private_subnet_id" {
  description = "The IDs of the private subnet"
  value       = var.enable_vpc ? module.vpc[0].private_subnet_id : null
}

output "vpc_public_subnet_id" {
  description = "The IDs of the public subnet"
  value       = var.enable_vpc ? module.vpc[0].public_subnet_id : null
}

output "vpc_private_subnet_name" {
  description = "The name of the private subnet"
  value       = var.enable_vpc ? module.vpc[0].private_subnet_name : null
}

output "vpc_public_subnet_name" {
  description = "The name of the public subnet"
  value       = var.enable_vpc ? module.vpc[0].public_subnet_name : null
}

output "vpc_nat_public_ips" {
  description = "Public Elastic IP created for the NAT Gateway"
  value       = var.enable_vpc ? module.vpc[0].nat_public_ips : null
}

output "vpc_nat_router_name" {
  description = "NAT Router Name"
  value       = var.enable_vpc ? module.vpc[0].nat_router_name : null
}

output "vpc_nat_name" {
  description = "NAT Name"
  value       = var.enable_vpc ? module.vpc[0].nat_name : null
}

output "vpc_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_vpc ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> vpc" : null
}