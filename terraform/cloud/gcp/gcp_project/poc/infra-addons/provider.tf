terraform {
  required_version = ">=1.10"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.13.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
  }

  backend "gcs" {
    prefix         = "infraaddons"
  }
}

# Calling infra-setup terraform state to fetch data
data "terraform_remote_state" "infra_setup_tf" {
  backend = "gcs"
  config = {
    bucket  = var.bucket
    prefix  = "infrasetup"
  }
}

provider "google" {
  project        = var.gcp_project
  region         = var.region
  zone           = var.default_zone
  default_labels = {
    managedby    = "terraform"
    environment  = var.project_env
    project      = var.project_name
  }
}

provider "postgresql" {
  host            = data.terraform_remote_state.infra_setup_tf.outputs.postgres_host
  port            = data.terraform_remote_state.infra_setup_tf.outputs.postgres_port
  database        = data.terraform_remote_state.infra_setup_tf.outputs.postgres_db_name
  username        = data.terraform_remote_state.infra_setup_tf.outputs.postgres_db_user
  password        = data.terraform_remote_state.infra_setup_tf.outputs.postgres_db_pass
  sslmode         = "require"
}