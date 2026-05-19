########## Locals ##########
locals {
  ssl_policy_prefix   = join("-", ([ var.project_name, var.project_env ]))
}

########## ssl_policy ##########
resource "google_compute_ssl_policy" "ssl_policy" {
  project             = var.gcp_project
  name                = "${local.ssl_policy_prefix}-ssl-policy"
  profile             = "RESTRICTED"
  min_tls_version     = "TLS_1_2"
}