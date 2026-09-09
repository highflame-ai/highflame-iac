data "google_project" "project_data" {}

locals {
  gke_authorized_networks                 = [
                                              {
                                                  name    = "public_cidr"
                                                  cidr    = "0.0.0.0/0"
                                              }
                                            ]
}

module "apis" {
  count                                   = var.enable_apis == true ? 1 : 0
  source                                  = "../../../../../modules/gcp/apis"
  gcp_project                             = var.gcp_project
  gcp_api_list                            = var.gcp_api_list
}

module "binary_authorization" {
  count                                   = var.enable_binary_authorization == true ? 1 : 0
  source                                  = "../../../../../modules/gcp/binary-authorization"
}

module "security_policies" {
  count                                   = var.enable_security_policies == true ? 1 : 0
  source                                  = "../../../../../modules/gcp/security-policies"
  project_name                            = var.project_name
  project_env                             = var.project_env
  gcp_project                             = var.gcp_project
}

module "ssl_policies" {
  count                                   = var.enable_ssl_policies == true ? 1 : 0
  source                                  = "../../../../../modules/gcp/ssl-policies"
  project_name                            = var.project_name
  project_env                             = var.project_env
  gcp_project                             = var.gcp_project
}

module "vpc" {
  count                                   = var.enable_vpc == true ? 1 : 0
  source                                  = "../../../../../modules/gcp/vpc"
  project_name                            = var.project_name
  project_env                             = var.project_env
  region                                  = var.region
  private_subnet_cidr                     = var.private_subnet_cidr
  public_subnet_cidr                      = var.public_subnet_cidr
}

module "svc_network" {
  count                                   = var.enable_svc_network == true ? 1 : 0
  source                                  = "../../../../../modules/gcp/svc-network"
  project_name                            = var.project_name
  project_env                             = var.project_env
  gcp_project                             = var.gcp_project
  private_service_cidr                    = var.private_service_cidr
  vpc_id                                  = module.vpc[0].vpc_id
}

module "postgres" {
  count                                   = var.enable_postgres == true ? 1 : 0
  depends_on                              = [ module.svc_network ]
  source                                  = "../../../../../modules/gcp/postgres"
  project_name                            = var.project_name
  project_env                             = var.project_env
  db_tier                                 = var.db_tier
  db_allocated_storage                    = var.db_allocated_storage
  region                                  = var.region
  gcp_project                             = var.gcp_project
  db_availability_type                    = var.db_availability_type
  vpc_id                                  = module.vpc[0].vpc_id
}

module "redis" {
  count                                   = var.enable_redis == true ? 1 : 0
  depends_on                              = [ module.vpc ]
  source                                  = "../../../../../modules/gcp/redis"
  project_name                            = var.project_name
  project_env                             = var.project_env
  region                                  = var.region
  redis_memory_size                       = var.redis_memory_size
  gcp_project                             = var.gcp_project
  redis_subnet_cidr                       = var.redis_subnet_cidr
  gcp_project_number                      = data.google_project.project_data.number
  vpc_id                                  = module.vpc[0].vpc_id
}

module "gke" {
  count                                   = var.enable_gke == true ? 1 : 0
  depends_on                              = [ module.vpc ]
  source                                  = "../../../../../modules/gcp/gke"
  project_name                            = var.project_name
  project_env                             = var.project_env
  region                                  = var.region
  gke_min_master_version                  = var.gke_min_master_version
  gcp_project                             = var.gcp_project
  redis_subnet_cidr                       = var.redis_subnet_cidr
  private_subnet_cidr                     = var.private_subnet_cidr
  public_subnet_cidr                      = var.public_subnet_cidr
  custom_egress_port_list                 = var.custom_egress_port_list
  vpc_name                                = module.vpc[0].vpc_name
  vpc_id                                  = module.vpc[0].vpc_id
  private_subnet_id                       = module.vpc[0].private_subnet_id
  svc_network_cidr_block                  = module.svc_network[0].svc_networking_ip_range
  gke_authorized_networks                 = local.gke_authorized_networks
  gcp_project_number                      = data.google_project.project_data.number
}

module "gke_custom_nodes" {
  count                                   = var.enable_gke == true ? 1 : 0
  source                                  = "../../../../../modules/gcp/gke-custom-nodes"
  project_name                            = var.project_name
  project_env                             = var.project_env
  gke_nodes_properties                    = var.gke_nodes_properties
  gke_cluster_version                     = module.gke[0].gke_master_version
  cluster_name                            = module.gke[0].gke_cluster_name
  cluster_location                        = module.gke[0].gke_cluster_location
  gke_service_account                     = module.gke[0].gke_service_account_email
  kms_key                                 = module.gke[0].gke_kms_key_id
}

module "gcp_logs" {
  count                                   = var.enable_gcp_logs == true ? 1 : 0
  source                                  = "../../../../../modules/gcp/gcp-logs"
  project_name                            = var.project_name
  project_env                             = var.project_env
  gcp_project                             = var.gcp_project
  gcp_log_retention_days                  = var.gcp_log_retention_days
  k8s_cluster_name                        = module.gke[0].gke_cluster_name
  service_namespace                       = var.service_namespace
}

module "gcs" {
  source                                  = "../../../../../modules/gcp/gcs"
  create_bucket_list                      = var.create_bucket_list
  gcp_project_number                      = data.google_project.project_data.number
}

module "svc_iam" {
  count                                   = var.enable_svc_iam == true ? 1 : 0
  source                                  = "../../../../../modules/gcp/svc-iam"
  project_name                            = var.project_name
  project_env                             = var.project_env
  gcp_project                             = var.gcp_project
  workload_identity                       = var.workload_identity
  svc_sa_role_list                        = var.svc_sa_role_list
  svc_bucket_list                         = module.gcs.gcs_bucket_name
}