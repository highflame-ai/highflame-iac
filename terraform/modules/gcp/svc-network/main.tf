########## Locals ##########
locals {
  svc_network_prefix                    = join("-", ([var.project_name, var.project_env]))
  cidr_parts                            = split("/", var.private_service_cidr)
  ip_address                            = local.cidr_parts[0]
  prefix                                = tonumber(local.cidr_parts[1])
}

########## Private_Network ##########
resource "google_compute_global_address" "private_cidr" {
  name                                  = "${local.svc_network_prefix}-private-networking"
  purpose                               = "VPC_PEERING"
  address_type                          = "INTERNAL"
  network                               = var.vpc_id
  prefix_length                         = local.prefix
  address                               = local.ip_address
}

resource "google_service_networking_connection" "private_connection" {
  network                               = var.vpc_id
  service                               = "servicenetworking.googleapis.com"
  reserved_peering_ranges               = [ google_compute_global_address.private_cidr.name ]
}