########## Locals ##########
locals {
  iam_prefix                            = join("-", ([var.project_name, var.project_env]))
}

########## Service_Account ##########
resource "google_service_account" "svc_sa" {
  account_id                            = "${local.iam_prefix}-${var.sa_suffix}"
  display_name                          = "${local.iam_prefix}-${var.sa_suffix}"
}

########## SA_Policy ##########
resource "google_service_account_iam_member" "workload_identity_binding" {
  for_each                              = { for ns in var.workload_identity : ns.namespace => ns }

  service_account_id                    = google_service_account.svc_sa.name
  role                                  = "roles/iam.workloadIdentityUser"
  member                                = "serviceAccount:${var.gcp_project}.svc.id.goog[${each.value.namespace}/${each.value.serviceaccount}]"
}

resource "google_project_iam_member" "svc_sa_binding" {
  count                                 = length(var.svc_sa_role_list)

  project                               = var.gcp_project
  role                                  = "${var.svc_sa_role_list[count.index]}"
  member                                = "serviceAccount:${google_service_account.svc_sa.email}"
}

resource "google_storage_bucket_iam_member" "bucket_admin" {
  for_each                              = toset(var.svc_bucket_list)
  bucket                                = each.value
  role                                  = "roles/storage.admin"
  member                                = "serviceAccount:${google_service_account.svc_sa.email}"
}