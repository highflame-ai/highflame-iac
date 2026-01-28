########## Kubernetes_Namespace ##########
resource "kubernetes_namespace" "deploy_namespace" {
  metadata {
    name        = var.service_namespace
    annotations = {
      name        = var.service_namespace
      project     = var.project_name
      project_env = var.project_env
    }
    labels = {
      name        = var.service_namespace
      project     = var.project_name
      project_env = var.project_env
    }
  }
}