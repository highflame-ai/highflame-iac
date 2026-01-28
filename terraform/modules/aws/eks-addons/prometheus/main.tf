########## Helm_Install_Prometheus ##########
resource "helm_release" "prometheus" {
  name             = "highflame-prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  version          = var.helm_version
  force_update     = false
  namespace        = var.namespace
  create_namespace = false
  values = [templatefile("../../../../../config/aws/${var.project_env}/helm/prometheus-values.yml", {
    service_namespace    = var.service_namespace
    prometheus_disk_size = var.prometheus_disk_size
    storage_classname    = var.storage_classname
  })]
}