########## Locals ##########
locals {
  vpc_prefix                         = join("-", [var.project_name, var.project_env])
}

########## VPC ##########
resource "google_compute_network" "vpc" {
  name                               = "${local.vpc_prefix}-vpc"
  routing_mode                       = "REGIONAL"
  auto_create_subnetworks            = false
}

resource "google_compute_subnetwork" "private_subnet" {
  name                               = "${local.vpc_prefix}-private"
  ip_cidr_range                      = var.private_subnet_cidr
  region                             = var.region
  network                            = google_compute_network.vpc.name
  private_ip_google_access           = true

  log_config {
    aggregation_interval             = "INTERVAL_5_SEC"
    flow_sampling                    = 0.5
    metadata                         = "INCLUDE_ALL_METADATA"
    # filter_expr                      = "connection.policy_attr.filter.policy_action == 'DENY'"
  }
}

resource "google_compute_subnetwork" "public_subnet" {
  name                               = "${local.vpc_prefix}-public"
  ip_cidr_range                      = var.public_subnet_cidr
  region                             = var.region
  network                            = google_compute_network.vpc.name
  private_ip_google_access           = true

  log_config {
    aggregation_interval             = "INTERVAL_5_SEC"
    flow_sampling                    = 0.5
    metadata                         = "INCLUDE_ALL_METADATA"
    # filter_expr                      = "connection.policy_attr.filter.policy_action == 'DENY'"
  }
}

resource "google_compute_router" "nat_router" {
  name                               = "${local.vpc_prefix}-router"
  network                            = google_compute_network.vpc.name
  region                             = var.region
}

resource "google_compute_address" "nat_ip" {
  name                               = "${local.vpc_prefix}-nat-ip"
  region                             = var.region
  address_type                       = "EXTERNAL"
  network_tier                       = "PREMIUM"
}

resource "google_compute_router_nat" "nat_gateway" {
  name                               = "${local.vpc_prefix}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [ google_compute_address.nat_ip.self_link ]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                             = google_compute_subnetwork.private_subnet.name
    source_ip_ranges_to_nat          = [ "ALL_IP_RANGES" ]
  }
}