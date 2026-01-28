data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "eks" {
  name                               = data.terraform_remote_state.infra_setup_tf.outputs.k8s_cluster_name
}

locals {
  aws_account_id                     = data.aws_caller_identity.current.account_id
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
  source                             = "../../../../../modules/aws/eks-addons/storageclass"
  project_name                       = var.project_name
  project_env                        = var.project_env
  storage_classname                  = var.storage_classname
  common_tags                        = local.tags
  kms_key_id                         = data.terraform_remote_state.infra_setup_tf.outputs.eks_kms_key_arn
}

module "autoscaler" {
  count                              = var.enable_autoscaler == true ? 1 : 0
  source                             = "../../../../../modules/aws/eks-addons/autoscaler"
  project_name                       = var.project_name
  project_env                        = var.project_env
  region                             = var.region
  k8s_cluster_name                   = data.terraform_remote_state.infra_setup_tf.outputs.k8s_cluster_name
  eks_cluster_oidc_provider          = data.terraform_remote_state.infra_setup_tf.outputs.eks_cluster_oidc_provider
  eks_cluster_oidc_provider_arn      = data.terraform_remote_state.infra_setup_tf.outputs.eks_cluster_oidc_provider_arn
}

module "ingress_alb_crds" {
  count                              = var.enable_ingress_alb_crds == true ? 1 : 0
  source                             = "../../../../../modules/aws/eks-addons/ingress-alb-crds"
}

module "ingress_alb" {
  count                              = var.enable_ingress_alb == true ? 1 : 0
  depends_on                         = [ module.ingress_alb_crds ]
  source                             = "../../../../../modules/aws/eks-addons/ingress-alb"
  project_name                       = var.project_name
  project_env                        = var.project_env
  ingress_replicas                   = var.ingress_replicas
  eks_cluster_oidc_provider_arn      = data.terraform_remote_state.infra_setup_tf.outputs.eks_cluster_oidc_provider_arn
  highflame_ingress_helm_version       = var.highflame_ingress_helm_version
  acm_certificate_arn                = var.frontend_acm_certificate_arn
  k8s_cluster_name                   = data.terraform_remote_state.infra_setup_tf.outputs.k8s_cluster_name
  public_subnet_ids                  = data.terraform_remote_state.infra_setup_tf.outputs.vpc_public_subnet_ids
  alb_security_group_ids             = data.terraform_remote_state.infra_setup_tf.outputs.alb_security_group_ids
}

module "prometheus" {
  count                              = var.enable_prometheus == true ? 1 : 0
  source                             = "../../../../../modules/aws/eks-addons/prometheus"
  project_name                       = var.project_name
  project_env                        = var.project_env
  namespace                          = var.service_namespace
  service_namespace                  = var.service_namespace
  prometheus_disk_size               = var.prometheus_disk_size
  storage_classname                  = var.storage_classname
}

module "grafana" {
  count                              = var.enable_grafana == true ? 1 : 0
  source                             = "../../../../../modules/aws/eks-addons/grafana"
  project_name                       = var.project_name
  project_env                        = var.project_env
  namespace                          = var.service_namespace
  storage_classname                  = var.storage_classname
  grafana_disk_size                  = var.grafana_disk_size
  grafana_domain                     = var.grafana_domain
  acm_certificate_arn                = var.grafana_acm_certificate_arn
  k8s_cluster_name                   = data.terraform_remote_state.infra_setup_tf.outputs.k8s_cluster_name
  public_subnet_ids                  = data.terraform_remote_state.infra_setup_tf.outputs.vpc_public_subnet_ids
  alb_security_group_ids             = data.terraform_remote_state.infra_setup_tf.outputs.alb_security_group_ids
}

module "metrics_server" {
  count                              = var.enable_metrics_server == true ? 1 : 0
  source                             = "../../../../../modules/aws/eks-addons/metrics-server"
  project_name                       = var.project_name
  project_env                        = var.project_env
}

module "fluent_bit" {
  count                              = var.enable_fluent_bit == true ? 1 : 0
  source                             = "../../../../../modules/aws/eks-addons/fluent-bit"
  project_name                       = var.project_name
  project_env                        = var.project_env
  region                             = var.region
  service_namespace                  = var.service_namespace
  cloudwatch_log_retention           = var.cloudwatch_log_retention
  k8s_cluster_name                   = data.terraform_remote_state.infra_setup_tf.outputs.k8s_cluster_name
}