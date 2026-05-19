########## Locals ##########
locals {
    kms_prefix                          = join("-", ([var.project_name, var.project_env]))
}

resource "random_id" "random" {
  byte_length                           = 2
}

########## KMS ##########
resource "google_kms_key_ring" "kms_keyring" {
  name                                  = "${local.kms_prefix}-default-keyring-${random_id.random.hex}"
  location                              = var.region
}

resource "google_kms_crypto_key" "kms_key" {
  name                                  = "${local.kms_prefix}-default-key-${random_id.random.hex}"
  key_ring                              = google_kms_key_ring.kms_keyring.id
  # rotation_period                       = "2592000s"
  purpose                               = "ENCRYPT_DECRYPT"

  version_template {
    algorithm                           = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level                    = "SOFTWARE"
  }
}