########## Locals ##########
locals {
  postgres_prefix                               = join("-", [ var.project_name, var.project_env ])
  kv_prefix                                     = join("-", ([ "jn", var.project_env ]))
}

resource "random_id" "random" {
  byte_length                                   = 2
}

########## Identity ##########
resource "azurerm_user_assigned_identity" "postgres" {
  name                                          = "${local.postgres_prefix}-postgres-identity"
  resource_group_name                           = var.resource_group_name
  location                                      = var.location
  tags                                          = var.tags
}

data "azurerm_resource_group" "rg" {
  name                                          = var.resource_group_name
}

resource "azurerm_role_assignment" "postgres" {
  count                                         = length(var.postgres_role_list)

  scope                                         = data.azurerm_resource_group.rg.id
  role_definition_name                          = var.postgres_role_list[count.index]
  principal_id                                  = azurerm_user_assigned_identity.postgres.principal_id
}

########## Firewall ##########
resource "azurerm_network_security_rule" "inbound_rule_5432" {
  name                                          = "allow-inbound-postgres"
  priority                                      = 105
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "5432"
  source_address_prefix                         = "${var.vnet_cidr}"
  destination_address_prefix                    = "*"
  resource_group_name                           = var.resource_group_name
  network_security_group_name                   = var.vnet_nsg_name
}

########## DNS ##########
resource "azurerm_private_dns_zone" "postgres" {
  name                                          = "privatelink.postgres.database.azure.com"
  resource_group_name                           = var.resource_group_name
  tags                                          = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                                          = "${local.postgres_prefix}-postgres-vnet-link"
  resource_group_name                           = var.resource_group_name
  private_dns_zone_name                         = azurerm_private_dns_zone.postgres.name
  virtual_network_id                            = var.vnet_id
  tags                                          = var.tags
}

########## KeyVault ##########
resource "azurerm_key_vault" "postgres" {
  name                                          = "${local.kv_prefix}-sql-${random_id.random.hex}"
  resource_group_name                           = var.resource_group_name
  location                                      = var.location
  tenant_id                                     = var.tenant_id
  sku_name                                      = "standard"
  soft_delete_retention_days                    = 7
  purge_protection_enabled                      = true
  enable_rbac_authorization                     = true
  tags                                          = var.tags
}