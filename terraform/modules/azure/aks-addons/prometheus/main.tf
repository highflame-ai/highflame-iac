########## Helm_Install_Prometheus ##########
resource "helm_release" "prometheus" {
  name             = "highflame-prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  version          = var.helm_version
  force_update     = false
  namespace        = var.namespace
  create_namespace = false
  values = [templatefile("../../../../../config/azure/${var.project_env}/helm/${var.prometheus_helm_value_file}", {
    service_namespace    = var.service_namespace
    prometheus_disk_size = var.prometheus_disk_size
    storage_classname    = var.storage_classname
  })]
}