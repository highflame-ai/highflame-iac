data "azurerm_client_config" "current" {}

locals {
  tags                               = merge(var.common_tags,
                                            {
                                              Project       = var.project_name
                                              Environment   = var.project_env
                                            })
}

module "namespace" {
  count                              = var.enable_namespace == true ? 1 : 0
  source                             = "../../../../../modules/highflame/namespace"
  project_name                       = var.project_name
  project_env                        = var.project_env
  service_namespace                  = var.service_namespace
}

module "docker_secret" {
  depends_on                         = [ module.namespace ]
  count                              = var.enable_docker_secret == true ? 1 : 0
  source                             = "../../../../../modules/highflame/docker-secret"
  project_name                       = var.project_name
  registry_server                    = var.registry_server
  registry_username                  = var.registry_username
  registry_password                  = var.registry_password
  secret_namespace_list              = [ var.service_namespace ]
  registry_email                     = var.registry_email
}

module "storageclass" {
  count                              = var.enable_storageclass == true ? 1 : 0
  source                             = "../../../../../modules/azure/aks-addons/storageclass"
  project_name                       = var.project_name
  project_env                        = var.project_env
  storage_classname                  = var.storage_classname
  des_id                             = data.terraform_remote_state.infra_setup_tf.outputs.des_id
  common_tags                        = local.tags
}

module "cert_manager" {
  count                              = var.enable_cert_manager == true ? 1 : 0
  source                             = "../../../../../modules/azure/aks-addons/cert-manager"
  project_name                       = var.project_name
  project_env                        = var.project_env
  cert_acme_email                    = var.cert_acme_email
}

module "prometheus" {
  depends_on                         = [ module.namespace, module.storageclass ]
  count                              = var.enable_prometheus == true ? 1 : 0
  source                             = "../../../../../modules/azure/aks-addons/prometheus"
  project_name                       = var.project_name
  project_env                        = var.project_env
  namespace                          = var.service_namespace
  service_namespace                  = var.service_namespace
  prometheus_disk_size               = var.prometheus_disk_size
  storage_classname                  = var.storage_classname
}

module "grafana" {
  depends_on                         = [ module.namespace, module.storageclass ]
  count                              = var.enable_grafana == true ? 1 : 0
  source                             = "../../../../../modules/azure/aks-addons/grafana"
  project_name                       = var.project_name
  project_env                        = var.project_env
  namespace                          = var.service_namespace
  grafana_domain                     = var.grafana_domain
  storage_classname                  = var.storage_classname
  grafana_disk_size                  = var.grafana_disk_size
}

module "aks_addons_secret" {
  count                              = var.enable_aks_addons_secret == true ? 1 : 0
  source                             = "../../../../../modules/azure/aks-addons-secret"
  project_name                       = var.project_name
  project_env                        = var.project_env
  resource_group_name                = var.resource_group_name
  location                           = var.location
  grafana_url                        = module.grafana[0].grafana_url
  grafana_username                   = module.grafana[0].grafana_username
  grafana_password                   = module.grafana[0].grafana_password
  tenant_id                          = data.azurerm_client_config.current.tenant_id
  tags                               = local.tags
}