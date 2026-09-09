terraform {
  required_version = ">=1.10"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.33.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.7"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }

  backend "azurerm" {
    container_name        = "terraform-state"
    key                   = "infrasetup/infrasetup.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id         = var.az_subscription_id
}