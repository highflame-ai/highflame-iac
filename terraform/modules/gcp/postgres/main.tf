########## Locals ##########
locals {
    postgres_prefix                     = join("-", ([var.project_name, var.project_env]))
}

resource "random_id" "random" {
  byte_length                           = 2
}

# ########## KMS ##########
# resource "google_kms_key_ring" "postgres_keyring" {
#   name                                  = "${local.postgres_prefix}-postgres-keyring-${random_id.random.hex}"
#   location                              = var.region
# }

# resource "google_kms_crypto_key" "postgres_key" {
#   name                                  = "${local.postgres_prefix}-postgres-key-${random_id.random.hex}"
#   key_ring                              = google_kms_key_ring.postgres_keyring.id
#   # rotation_period                       = "2592000s"
#   purpose                               = "ENCRYPT_DECRYPT"

#   version_template {
#     algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
#     protection_level = "SOFTWARE"
#   }
# }

########## Random_Pass ##########
resource "random_password" "db_password" {
  length                                = 16
  special                               = false
}

########## Postgres ##########
resource "google_sql_database_instance" "postgres_instance" {
  name                                  = "${local.postgres_prefix}-postgres"
  database_version                      = var.db_version
  region                                = var.region
  # encryption_key_name                   = google_kms_crypto_key.postgres_key.id

  settings {
    edition                             = "ENTERPRISE"
    tier                                = var.db_tier
    availability_type                   = var.db_availability_type
    disk_autoresize                     = true
    disk_size                           = var.db_allocated_storage
    disk_type                           = "PD_SSD"
    deletion_protection_enabled         = true
    user_labels = {
      managedby                         = "terraform"
      environment                       = var.project_env
      project                           = var.project_name
    }

    ip_configuration {
      ipv4_enabled                      = false
      private_network                   = var.vpc_id
      ssl_mode                          = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"

      # dynamic "authorized_networks" {
      #   for_each = var.sql_authorized_networks
      #   content {
      #     name  = authorized_networks.value.name
      #     value = authorized_networks.value.cidr
      #   }
      # }
    }

    backup_configuration {
      enabled                           = true
      # location                          = "us"
      point_in_time_recovery_enabled    = true
      start_time                        = var.backup_start_time
      transaction_log_retention_days    = var.backup_retention_period
      backup_retention_settings {
        retention_unit   = "COUNT"
        retained_backups = var.backup_retention_period
      }
    }

    maintenance_window {
      day                = 2
      hour               = 1
      update_track       = "stable"
    }
  }

  lifecycle {
    ignore_changes = [ settings[0].disk_size ]
  }
}

resource "google_sql_database" "postgres_database" {
  name                                  = var.db_name
  instance                              = google_sql_database_instance.postgres_instance.name

  lifecycle {
    ignore_changes = [ name ]
  }
}

resource "google_sql_user" "postgres_user" {
  name                                  = var.db_user
  instance                              = google_sql_database_instance.postgres_instance.name
  password                              = random_password.db_password.result

  lifecycle {
    ignore_changes = [ password ]
  }
}

########## Random_Pass_javelin_customers ##########
resource "random_password" "javelin_customers_password" {
  length                                = 16
  special                               = false
}

########## Random_Pass_javelin_admins ##########
resource "random_password" "javelin_admins_password" {
  length                                = 16
  special                               = false
}

########## Secret_manager ##########
resource "google_secret_manager_secret" "postgres_secret" {
  secret_id                             = "${local.postgres_prefix}-postgres-${random_id.random.hex}"
  version_destroy_ttl                   = "2592000s"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "postgres_secret_version" {
  secret      = google_secret_manager_secret.postgres_secret.id
  secret_data = <<EOF
  {
    "dbname"            : "${google_sql_database.postgres_database.name}",
    "sql_id"            : "${google_sql_database_instance.postgres_instance.id}",
    "username"          : "${google_sql_user.postgres_user.name}",
    "password"          : "${random_password.db_password.result}",
    "javelin_customers" : "${random_password.javelin_customers_password.result}",
    "javelin_admins"    : "${random_password.javelin_admins_password.result}",
    "host"              : "${google_sql_database_instance.postgres_instance.private_ip_address}",
    "port"              : "5432",
    "connection_name"   : "${google_sql_database_instance.postgres_instance.connection_name}"
  }
EOF

  lifecycle {
    ignore_changes = [ secret_data ]
  }
}