########## Enable_Apis ##########
resource "google_project_service" "enable_apis" {
  for_each                    = toset(var.gcp_api_list)
  disable_on_destroy          = true
  project                     = var.gcp_project
  service                     = each.value
}