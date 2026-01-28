########## Locals ##########
locals {
  ssl_prefix                                      = join("-", [ var.project_name, var.project_env ])
  kv_prefix                                       = join("-", ([ "jn", var.project_env ]))
}

resource "random_id" "random" {
  byte_length                                     = 2
}

########## KeyVault ##########
resource "azurerm_key_vault" "ssl" {
  name                                            = "${local.kv_prefix}-ssl-${random_id.random.hex}"
  location                                        = var.location
  resource_group_name                             = var.resource_group_name
  tenant_id                                       = var.tenant_id
  sku_name                                        = "standard"
  soft_delete_retention_days                      = 7
  purge_protection_enabled                        = true
  enable_rbac_authorization                       = true

  network_acls {
    bypass                                        = "AzureServices"
    default_action                                = "Allow"
  }

  tags                                            = var.tags
}

########## Self_Signed ##########
resource "azurerm_key_vault_certificate" "ssl" {
  count                                           = var.enable_self_signed_cert == true ? 1 : 0

  name                                            = "${local.ssl_prefix}-self-signed-cert"
  key_vault_id                                    = azurerm_key_vault.ssl.id

  certificate_policy {
    issuer_parameters {
      name                                        = "Self"
    }

    key_properties {
      exportable                                  = true
      key_size                                    = 2048
      key_type                                    = "RSA"
      reuse_key                                   = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }
      trigger {
        days_before_expiry                        = 10
      }
    }

    secret_properties {
      content_type                                = "application/x-pkcs12"
    }

    x509_certificate_properties {
      subject                                     = "CN=highflame.self"
      key_usage                                   = [
                                                      "cRLSign",
                                                      "dataEncipherment",
                                                      "decipherOnly",
                                                      "digitalSignature",
                                                      "encipherOnly",
                                                      "keyAgreement",
                                                      "keyCertSign",
                                                      "keyEncipherment",
                                                      "nonRepudiation"
                                                    ]
      validity_in_months                          = 120
    }
  }
  tags                                            = var.tags
}
