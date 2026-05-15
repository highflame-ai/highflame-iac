########## Kubernetes_Namespace ##########
resource "kubernetes_namespace" "deploy_namespace" {
  metadata {
    name        = var.namespace
    annotations = {
      name        = var.namespace
      project     = var.project_name
      project_env = var.project_env
    }
    labels = {
      name        = var.namespace
      project     = var.project_name
      project_env = var.project_env
    }
  }
}

########## Helm_Install_FluentBit ##########
resource "helm_release" "fluent_bit_daemonset" {
  depends_on       = [ kubernetes_namespace.deploy_namespace ]
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  version          = var.helm_version
  name             = "fluent-bit"
  namespace        = var.namespace
  create_namespace = false
  values = [
    templatefile("../../../../../config/aws/helm/fluent-bit-${var.fluent_output}-values.yml", {
      k8s_cluster_name                      = var.k8s_cluster_name
      service_namespace                     = var.service_namespace
      region                                = var.region
      cloudwatch_log_retention              = var.cloudwatch_log_retention
      project_name                          = var.project_name
    })
  ]
}