########## Random_Pass ##########
resource "random_password" "grafana_secret" {
  length  = 16
  special = false
}

########## Grafana_Dashboards ##########
locals {
  config_files = fileset("../../../../../config/common/template/grafana-dashboard/", "*.json")
}

resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "${var.project_name}-grafana-dashboards"
    namespace = var.namespace
  }

  data = {
    for file in local.config_files : file => file("../../../../../config/common/template/grafana-dashboard/${file}")
  }
}

########## Helm_Install_Grafana ##########
resource "helm_release" "grafana" {
  name             = "highflame-grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  version          = var.helm_version
  force_update     = false
  namespace        = var.namespace
  create_namespace = false
  values = [
    templatefile("../../../../../config/aws/${var.project_env}/helm/grafana-values.yml", {
      project_name            = var.project_name
      grafana_disk_size       = var.grafana_disk_size
      storage_classname       = var.storage_classname
      grafana_secret          = random_password.grafana_secret.result
      prometheus_url          = var.prometheus_url
      grafana_subpath         = var.grafana_subpath
      grafana_domain         = var.grafana_domain
      public_subnet_ids      = join(", ", var.public_subnet_ids)
      acm_certificate_arn    = var.acm_certificate_arn
      k8s_cluster_name       = var.k8s_cluster_name
      alb_security_group_ids = var.alb_security_group_ids
    })
  ]
}