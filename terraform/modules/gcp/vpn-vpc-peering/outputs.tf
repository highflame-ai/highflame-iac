output "vpn_vpc_peering_a" {
  description = "The ID of the VPC Peering - a"
  value       = google_compute_network_peering.vpc_peering_a.id
}

output "vpn_vpc_peering_b" {
  description = "The ID of the VPC Peering - b"
  value       = google_compute_network_peering.vpc_peering_b.id
}