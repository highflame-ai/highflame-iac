terraform {
  required_version = ">=1.10"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.33.0"
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

  backend "azurerm" {
    container_name        = "terraform-state"
    key                   = "infraaddons/infraaddons.tfstate"
  }
}

# Calling infra-setup terraform state to fetch data
data "terraform_remote_state" "infra_setup_tf" {
  backend = "azurerm"
  config = {
    resource_group_name   = var.resource_group_name
    storage_account_name  = var.storage_account_name
    container_name        = "terraform-state"
    key                   = "infrasetup/infrasetup.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id         = var.az_subscription_id
}

provider "postgresql" {
  host                    = data.terraform_remote_state.infra_setup_tf.outputs.postgres_primary_private_ip
  port                    = data.terraform_remote_state.infra_setup_tf.outputs.postgres_primary_port
  database                = data.terraform_remote_state.infra_setup_tf.outputs.postgres_primary_db_name
  username                = data.terraform_remote_state.infra_setup_tf.outputs.postgres_primary_db_user
  password                = data.terraform_remote_state.infra_setup_tf.outputs.postgres_primary_db_pass
  sslmode                 = "require"
}