output "vpc_id" {
  description = "The VPC ID"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The VPC Name"
  value       = google_compute_network.vpc.name
}

output "private_cidr_block" {
  description = "Private Subnet CIDR block"
  value       = var.private_subnet_cidr
}

output "public_cidr_block" {
  description = "Public Subnet CIDR block"
  value       = var.public_subnet_cidr
}

output "private_subnet_id" {
  description = "The IDs of the private subnet"
  value       = google_compute_subnetwork.private_subnet.id
}

output "public_subnet_id" {
  description = "The IDs of the public subnet"
  value       =  google_compute_subnetwork.public_subnet.id
}

output "private_subnet_name" {
  description = "The name of the private subnet"
  value       = google_compute_subnetwork.private_subnet.name
}

output "public_subnet_name" {
  description = "The name of the public subnet"
  value       =  google_compute_subnetwork.public_subnet.name
}

output "nat_public_ips" {
  description = "Public Elastic IP created for the NAT Gateway"
  value       = google_compute_address.nat_ip.address
}

output "nat_router_name" {
  description = "NAT Router Name"
  value       = google_compute_router.nat_router.name
}

output "nat_name" {
  description = "NAT Name"
  value       = google_compute_router_nat.nat_gateway.name
}