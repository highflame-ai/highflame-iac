########## Locals ##########
locals {
  vpc_peering_prefix                = join("-", [ var.project_name, var.project_env ])
}

########## VPC_Peering ##########
resource "google_compute_network_peering" "vpc_peering_a" {
  name                              = "${local.vpc_peering_prefix}-vpn-vpc-peering-a"
  network                           = var.vpn_vpc
  peer_network                      = var.deploy_vpc
  export_custom_routes              = true
  import_custom_routes              = true
  stack_type                        = "IPV4_ONLY"
}

resource "google_compute_network_peering" "vpc_peering_b" {
  name                              = "${local.vpc_peering_prefix}-vpn-vpc-peering-b"
  network                           = var.deploy_vpc
  peer_network                      = var.vpn_vpc
  export_custom_routes              = true
  import_custom_routes              = true
  stack_type                        = "IPV4_ONLY"
}