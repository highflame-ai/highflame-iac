resource "random_id" "random" {
  for_each                              = { for gcs in var.create_bucket_list : gcs.name => gcs }
  byte_length                           = 2
}

########## KMS ##########
resource "google_kms_key_ring" "gcs_bucket" {
  for_each                              = { for gcs in var.create_bucket_list : gcs.name => gcs }
  name                                  = "${each.value.name}-${random_id.random[each.key].hex}"
  location                              = each.value.region
}

resource "google_kms_crypto_key" "gcs_bucket" {
  for_each                              = { for gcs in var.create_bucket_list : gcs.name => gcs }
  name                                  = "${each.value.name}-${random_id.random[each.key].hex}"
  key_ring                              = google_kms_key_ring.gcs_bucket[each.key].id
  # rotation_period                       = "2592000s"
  purpose                               = "ENCRYPT_DECRYPT"

  version_template {
    algorithm                           = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level                    = "SOFTWARE"
  }
}

########## GCS_SA ##########
resource "google_kms_crypto_key_iam_member" "gcs_default_role_kms_enc_dec" {
  for_each                              = { for gcs in var.create_bucket_list : gcs.name => gcs }
  crypto_key_id                         = google_kms_crypto_key.gcs_bucket[each.key].id
  role                                  = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member                                = "serviceAccount:service-${var.gcp_project_number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "gcs_default_role_kms_viewer" {
  for_each                              = { for gcs in var.create_bucket_list : gcs.name => gcs }
  crypto_key_id                         = google_kms_crypto_key.gcs_bucket[each.key].id
  role                                  = "roles/cloudkms.viewer"
  member                                = "serviceAccount:service-${var.gcp_project_number}@gs-project-accounts.iam.gserviceaccount.com"
}

########## GCS_Bucket ##########
resource "google_storage_bucket" "gcs_bucket" {
  for_each                              = { for gcs in var.create_bucket_list : gcs.name => gcs }
  name                                  = each.value.name
  location                              = upper(each.value.region)
  force_destroy                         = false
  public_access_prevention              = "enforced"
  uniform_bucket_level_access           = true
  storage_class                         = each.value.storage_class

  versioning {
    enabled                             = false
  }

  encryption {
    default_kms_key_name                = google_kms_crypto_key.gcs_bucket[each.key].id
  }
}