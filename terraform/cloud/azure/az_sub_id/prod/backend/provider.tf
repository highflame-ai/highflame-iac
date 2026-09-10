terraform {
  required_version = ">=1.10"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.33.0"
    }
  }

# Comment this out when initialising the backend_resources first time.
# terraform init -backend-config="backend.tfvars"
# terraform apply
# uncomment the azure storage backend
# terraform init -backend-config="backend.tfvars" -- It will ask you to push the statefile from local to azure storage
  backend "azurerm" {
    container_name        = "terraform-state"
    key                   = "backend/backend.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id         = var.az_subscription_id
}