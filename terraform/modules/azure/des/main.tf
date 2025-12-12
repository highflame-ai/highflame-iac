########## Locals ##########
locals {
  des_prefix                          = join("-", [ var.project_name, var.project_env ])
  kv_prefix                           = join("-", ([ "jn", var.project_env ]))
}

resource "random_id" "random" {
  byte_length                         = 2
}

########## KeyVault ##########
resource "azurerm_key_vault" "des" {
  name                                = "${local.kv_prefix}-des-${random_id.random.hex}"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  tenant_id                           = var.tenant_id
  sku_name                            = "standard"
  soft_delete_retention_days          = 7
  purge_protection_enabled            = true
  enable_rbac_authorization           = true

  network_acls {
    bypass                            = "AzureServices"
    default_action                    = "Allow"
  }

  tags                                = var.tags
}

resource "azurerm_key_vault_key" "des" {
  name                                = "${local.des_prefix}-des-key"
  key_vault_id                        = azurerm_key_vault.des.id
  key_type                            = "RSA"
  key_size                            = 2048
  key_opts                            = [
                                          "decrypt",
                                          "encrypt",
                                          "wrapKey",
                                          "unwrapKey"
                                        ]
  tags                                = var.tags
}

resource "azurerm_disk_encryption_set" "des" {
  name                                = "${local.des_prefix}-des"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  key_vault_key_id                    = azurerm_key_vault_key.des.id
  identity {
    type                              = "SystemAssigned"
  }
  tags                                = var.tags
}

resource "azurerm_role_assignment" "des" {
  count                               = length(var.des_keyvault_role_list)

  scope                               = azurerm_key_vault.des.id
  role_definition_name                = var.des_keyvault_role_list[count.index]
  principal_id                        = azurerm_disk_encryption_set.des.identity[0].principal_id
}