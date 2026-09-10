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