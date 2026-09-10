################################################## VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.enable_vpc ? module.vpc[0].vpc_id : null
}

output "vpc_azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.enable_vpc ? module.vpc[0].azs : null
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = var.enable_vpc ? module.vpc[0].vpc_cidr_block : null
}

output "vpc_private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = var.enable_vpc ? module.vpc[0].private_subnet_ids : null
}

output "vpc_public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = var.enable_vpc ? module.vpc[0].public_subnet_ids : null
}

output "vpc_database_subnet_ids" {
  description = "The IDs of the database subnets"
  value       = var.enable_vpc ? module.vpc[0].database_subnet_ids : null
}

output "vpc_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = var.enable_vpc ? module.vpc[0].nat_public_ips : null
}

output "vpc_public_route_table_ids" {
  description = "The IDs of the public route table"
  value       = var.enable_vpc ? module.vpc[0].public_route_table_ids : null
}

output "vpc_private_route_table_ids" {
  description = "The IDs of the private route table"
  value       = var.enable_vpc ? module.vpc[0].private_route_table_ids : null
}

output "vpc_database_route_table_ids" {
  description = "The IDs of the database route table"
  value       = var.enable_vpc ? module.vpc[0].database_route_table_ids : null
}

output "vpc_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_vpc ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> vpc" : null
}