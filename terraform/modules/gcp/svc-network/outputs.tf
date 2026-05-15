output "svc_networking_ip_range" {
  description = "Private networking IP range"
  value       = "${google_compute_global_address.private_cidr.address}/${google_compute_global_address.private_cidr.prefix_length}"
}

output "svc_networking_name" {
  description = "Private networking name"
  value       = google_compute_global_address.private_cidr.name
}