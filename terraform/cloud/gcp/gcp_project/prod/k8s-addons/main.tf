data "google_client_config" "current" {}

module "namespace" {
  count                              = var.enable_namespace == true ? 1 : 0
  source                             = "../../../../../modules/highflame/namespace"
  project_name                       = var.project_name
  project_env                        = var.project_env
  service_namespace                  = var.service_namespace
}

module "docker_secret" {
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
  source                             = "../../../../../modules/gcp/gke-addons/storageclass"
  project_name                       = var.project_name
  project_env                        = var.project_env
  storage_classname                  = var.storage_classname
  kms_key_id                         = data.terraform_remote_state.infra_setup_tf.outputs.gke_kms_key_id
}