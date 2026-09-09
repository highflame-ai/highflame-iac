locals {
  backend_tags                      = merge(var.common_tags,
                                            {
                                              Project       = var.project_name
                                              Environment   = var.project_env
                                            })
}

resource "azurerm_resource_group" "resource_grp" {
  count                             = terraform.workspace == "default" ? 1 : 0

  name                              = var.resource_group_name
  location                          = var.location
  tags                              = local.backend_tags

  lifecycle {
    prevent_destroy                 = true
  }
}

resource "azurerm_storage_account" "backend" {
  count                             = terraform.workspace == "default" ? 1 : 0

  name                              = var.storage_account_name
  resource_group_name               = azurerm_resource_group.resource_grp[0].name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  public_network_access_enabled     = true
  tags                              = local.backend_tags

  lifecycle {
    prevent_destroy                 = true
  }
}

resource "azurerm_storage_container" "backend" {
  count                             = terraform.workspace == "default" ? 1 : 0

  name                              = "terraform-state"
  storage_account_id                = azurerm_storage_account.backend[0].id
  container_access_type             = "private"

  lifecycle {
    prevent_destroy                 = true
  }
}

resource "azurerm_management_lock" "backend" {
  count                             = terraform.workspace == "default" ? 1 : 0

  name                              = "${var.storage_account_name}-lock"
  scope                             = azurerm_storage_account.backend[0].id
  lock_level                        = "CanNotDelete"  # or "ReadOnly"
  notes                             = "ManagedBy Terraform"

  lifecycle {
    prevent_destroy                 = true
  }
}