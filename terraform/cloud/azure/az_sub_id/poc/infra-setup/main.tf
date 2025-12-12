data "http" "my_public_ip" {
  url                                           = "https://ifconfig.co/json"
  request_headers                               = {
                                                    Accept = "application/json"
                                                  }
}

data "azurerm_client_config" "current" {}

locals {
  my_public_ip_json                             = jsondecode(data.http.my_public_ip.response_body)
  tags                                          = merge(var.common_tags,
                                                        {
                                                          Project       = var.project_name
                                                          Environment   = var.project_env
                                                        })
  aks_authorized_networks                       = [ "0.0.0.0/0" ]
}

module "self_keyvault_access" {
  count                                         = var.enable_self_keyvault_access == true ? 1 : 0
  source                                        = "../../../../../modules/azure/self-keyvault-access"
  ad_object_id                                  = var.ad_object_id
  # ad_object_id                                  = data.azurerm_client_config.current.object_id
  resource_group_name                           = var.resource_group_name
}

module "vnet" {
  count                                         = var.enable_vnet == true ? 1 : 0
  source                                        = "../../../../../modules/azure/vnet"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  vnet_cidr                                     = var.vnet_cidr
  private_subnet_cidr                           = var.private_subnet_cidr
  public_subnet_cidr                            = var.public_subnet_cidr
  appgw_subnet_cidr                             = var.appgw_subnet_cidr
  nat_ip_count                                  = var.nat_ip_count
  vnet_all_egress_enable                        = var.vnet_all_egress_enable
  tags                                          = local.tags
}

module "des" {
  count                                         = var.enable_des == true ? 1 : 0
  source                                        = "../../../../../modules/azure/des"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  tenant_id                                     = data.azurerm_client_config.current.tenant_id
  tags                                          = local.tags
}

module "redis" {
  count                                         = var.enable_redis == true ? 1 : 0
  source                                        = "../../../../../modules/azure/redis"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  vnet_cidr                                     = var.vnet_cidr
  redis_sku                                     = var.redis_sku
  redis_capacity                                = var.redis_capacity
  vnet_nsg_name                                 = module.vnet[0].vnet_nsg_name
  private_subnet_id                             = module.vnet[0].private_subnet_id
  vnet_id                                       = module.vnet[0].vnet_id
  tags                                          = local.tags
}

module "postgres_deps" {
  count                                         = var.enable_postgres_deps == true ? 1 : 0
  source                                        = "../../../../../modules/azure/postgres-deps"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  vnet_cidr                                     = var.vnet_cidr
  vnet_nsg_name                                 = module.vnet[0].vnet_nsg_name
  vnet_id                                       = module.vnet[0].vnet_id
  tenant_id                                     = data.azurerm_client_config.current.tenant_id
  tags                                          = local.tags
}

module "postgres_primary" {
  count                                         = var.enable_postgres_primary == true ? 1 : 0
  source                                        = "../../../../../modules/azure/postgres-primary"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  postgres_storage_mb                           = var.postgres_storage_mb
  postgres_sku_name                             = var.postgres_sku_name
  enable_delete_lock                            = var.enable_delete_lock
  postgres_storage_tier                         = var.postgres_storage_tier
  postgres_server_params                        = var.postgres_server_params
  des_keyvault_key_id                           = module.des[0].des_keyvault_key_id
  private_subnet_id                             = module.vnet[0].private_subnet_id
  private_dns_zone_id                           = module.postgres_deps[0].postgres_private_dns_zone_id
  identity_id                                   = module.postgres_deps[0].postgres_identity_id
  secret_keyvault_id                            = module.postgres_deps[0].postgres_keyvault_id
  tags                                          = local.tags
}

module "postgres_secondary" {
  count                                         = var.enable_postgres_secondary == true ? 1 : 0
  source                                        = "../../../../../modules/azure/postgres-secondary"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  postgres_storage_mb                           = var.postgres_storage_mb
  postgres_sku_name                             = var.postgres_sku_name
  postgres_source_server_id                     = var.postgres_source_server_id
  enable_delete_lock                            = var.enable_delete_lock
  postgres_storage_tier                         = var.postgres_storage_tier
  postgres_server_params                        = var.postgres_server_params
  des_keyvault_key_id                           = module.des[0].des_keyvault_key_id
  private_subnet_id                             = module.vnet[0].private_subnet_id
  private_dns_zone_id                           = module.postgres_deps[0].postgres_private_dns_zone_id
  identity_id                                   = module.postgres_deps[0].postgres_identity_id
  secret_keyvault_id                            = module.postgres_deps[0].postgres_keyvault_id
  tags                                          = local.tags
}

module "ssl_keyvault" {
  count                                         = var.enable_ssl_keyvault == true ? 1 : 0
  source                                        = "../../../../../modules/azure/ssl-keyvault"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  enable_self_signed_cert                       = var.enable_self_signed_cert
  tenant_id                                     = data.azurerm_client_config.current.tenant_id
  tags                                          = local.tags
}

module "application_gw" {
  count                                         = var.enable_application_gw == true ? 1 : 0
  source                                        = "../../../../../modules/azure/application-gateway"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  ssl_keyvault_secret_ids                       = var.ssl_keyvault_secret_ids
  appgw_zones                                   = var.appgw_zones
  ssl_keyvault_id                               = module.ssl_keyvault[0].ssl_keyvault_id
  appgw_subnet_id                               = module.vnet[0].appgw_subnet_id
  tags                                          = local.tags
}

module "aks" {
  count                                         = var.enable_aks == true ? 1 : 0
  source                                        = "../../../../../modules/azure/aks"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  aks_auth_object_ids                           = [ var.ad_object_id ]
  aks_default_node_vm_size                      = var.aks_default_node_vm_size
  aks_version                                   = var.aks_version
  aks_service_cidr                              = var.aks_service_cidr
  aks_dns_service_ip                            = var.aks_dns_service_ip
  aks_log_retention_in_days                     = var.aks_log_retention_in_days
  private_subnet_id                             = module.vnet[0].private_subnet_id
  appgw_subnet_id                               = module.vnet[0].appgw_subnet_id
  des_id                                        = module.des[0].des_id
  application_gw_id                             = module.application_gw[0].appgw_id
  application_gw_identity_id                    = module.application_gw[0].appgw_identity_id
  tenant_id                                     = data.azurerm_client_config.current.tenant_id
  aks_authorized_networks                       = local.aks_authorized_networks
  tags                                          = local.tags
}

module "aks_custom_nodepool" {
  count                                         = var.enable_aks_custom_nodepool == true ? 1 : 0
  source                                        = "../../../../../modules/azure/aks-custom-nodes"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  aks_nodes_properties                          = var.aks_nodes_properties
  aks_cluster_id                                = module.aks[0].aks_cluster_id
  private_subnet_id                             = module.vnet[0].private_subnet_id
  tags                                          = local.tags
}

module "svc_iam" {
  count                                         = var.enable_svc_iam == true ? 1 : 0
  source                                        = "../../../../../modules/azure/svc-iam"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  location                                      = var.location
  resource_group_name                           = var.resource_group_name
  workload_identity                             = var.workload_identity
  aks_oidc_issuer_url                           = module.aks[0].aks_oidc_issuer_url
  tags                                          = local.tags
}

module "traffic_manager" {
  count                                         = var.enable_traffic_manager == true ? 1 : 0
  source                                        = "../../../../../modules/azure/traffic-manager"
  project_name                                  = var.project_name
  project_env                                   = var.project_env
  resource_group_name                           = var.resource_group_name
  appgw_ip                                      = module.application_gw[0].appgw_ip_address
  tags                                          = local.tags
}