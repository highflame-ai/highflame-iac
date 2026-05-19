########## Locals ##########
locals {
  redis_prefix                        = join("-", [var.project_name, var.project_env])
  cloud_redis_service_account         = "service-${var.gcp_project_number}@cloud-redis.iam.gserviceaccount.com"
}

resource "random_id" "random" {
  byte_length                           = 2
}

resource "google_project_iam_member" "redis_sa_role_binding" {
  project                               = var.gcp_project
  role                                  = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member                                = "serviceAccount:${local.cloud_redis_service_account}"
}

########## KMS ##########
resource "google_kms_key_ring" "redis_keyring" {
  name                                  = "${local.redis_prefix}-redis-keyring-${random_id.random.hex}"
  location                              = var.region
}

resource "google_kms_crypto_key" "redis_key" {
  name                                  = "${local.redis_prefix}-redis-key-${random_id.random.hex}"
  key_ring                              = google_kms_key_ring.redis_keyring.id
  # rotation_period                       = "2592000s"
  purpose                               = "ENCRYPT_DECRYPT"

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
}

########## Redis ##########
resource "google_redis_instance" "redis_instance" {
  depends_on                          = [ google_project_iam_member.redis_sa_role_binding ]
  name                                = "${local.redis_prefix}-redis"
  display_name                        = "${local.redis_prefix}-redis"
  tier                                = var.redis_tier
  reserved_ip_range                   = var.redis_subnet_cidr
  memory_size_gb                      = var.redis_memory_size
  region                              = var.region
  redis_version                       = var.redis_version
  authorized_network                  = var.vpc_id
  customer_managed_key                = google_kms_crypto_key.redis_key.id
  auth_enabled                        = true
  transit_encryption_mode             = "SERVER_AUTHENTICATION"
  replica_count                       = 1

  maintenance_policy {
    weekly_maintenance_window {
      day = "TUESDAY"
      start_time {
        hours   = 1
        minutes = 0
        seconds = 0
        nanos   = 0
      }
    }
  }
}

########## Secret_manager ##########
resource "google_secret_manager_secret" "redis_secret" {
  secret_id                             = "${local.redis_prefix}-redis-${random_id.random.hex}"
  version_destroy_ttl                   = "2592000s"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "redis_secret_version" {
  secret      = google_secret_manager_secret.redis_secret.id
  secret_data = <<EOF
  {
    "host"            : "${google_redis_instance.redis_instance.host}",
    "port"            : "${google_redis_instance.redis_instance.port}",
    "password"        : "${google_redis_instance.redis_instance.auth_string}"
  }
EOF

  # lifecycle {
  #   ignore_changes = [ secret_data ]
  # }
}