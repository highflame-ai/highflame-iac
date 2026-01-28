## Terraform Backend Variables
resource_group_name                         = "highflame-poc"
storage_account_name                        = "highflametfstatepoc"
## Enable required services
enable_self_keyvault_access                 = false
enable_vnet                                 = false
enable_des                                  = false
enable_redis                                = false
enable_postgres_deps                        = false
enable_postgres_primary                     = false
enable_postgres_secondary                   = false
enable_ssl_keyvault                         = false
enable_application_gw                       = false
enable_aks                                  = false
enable_aks_custom_nodepool                  = false
enable_svc_iam                              = false
enable_traffic_manager                      = false
## Resource Variables
common_tags                                 = {
                                                ManagedBy   = "Terraform"
                                              }
az_subscription_id                          = ""
ad_object_id                                = ""
enable_delete_lock                          = true
project_name                                = "highflame"
project_env                                 = "poc"
location                                    = "East US"
vnet_all_egress_enable                      = true
vnet_cidr                                   = "10.51.0.0/16"
public_subnet_cidr                          = "10.51.0.0/19"
private_subnet_cidr                         = "10.51.32.0/19"
appgw_subnet_cidr                           = "10.51.64.0/19"
nat_ip_count                                = 2
redis_sku                                   = "Standard" # Basic
redis_capacity                              = 3
postgres_storage_mb                         = 65536
postgres_storage_tier                       = "P30"
postgres_sku_name                           = "GP_Standard_D4ads_v5"
postgres_source_server_id                   = ""
workload_identity                           = [
                                                {
                                                  id             = 1
                                                  namespace      = "highflame-poc"
                                                  serviceaccount = "highflame-core"
                                                },
                                                {
                                                  id             = 2
                                                  namespace      = "highflame-poc"
                                                  serviceaccount = "highflame-admin"
                                                }
                                              ]
enable_self_signed_cert                     = true
appgw_zones                                 = [ "1", "2", "3" ]
ssl_keyvault_secret_ids                     = []
aks_version                                 = 1.33
aks_default_node_vm_size                    = "Standard_D4as_v6"
aks_service_cidr                            = "172.20.0.0/16"
aks_dns_service_ip                          = "172.20.0.10"
aks_log_retention_in_days                   = 30
aks_nodes_properties                        = [
                                                {
                                                  name                    = "general"
                                                  aks_node_vm_size        = "Standard_D4as_v6"
                                                  aks_node_priority       = "Regular" # "Spot" or "Regular"
                                                  aks_node_min_count      = 3
                                                  aks_node_max_count      = 6
                                                }
                                                # {
                                                #   name                    = "gpu"
                                                #   aks_node_vm_size        = "Standard_NC4as_T4_v3"
                                                #   aks_node_priority       = "Regular" # "Spot" or "Regular"
                                                #   aks_node_min_count      = 1
                                                #   aks_node_max_count      = 1
                                                # }
                                              ]