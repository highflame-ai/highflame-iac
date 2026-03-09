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

########## Helm_Install_Metrics_Server ##########
resource "helm_release" "metrics_server" {
  depends_on       = [ kubernetes_namespace.deploy_namespace ]
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server"
  chart            = "metrics-server"
  version          = var.helm_version
  force_update     = false
  namespace        = var.namespace
  create_namespace = false
  set              = [
                        {
                          name  = "replicas"
                          value = "3"
                        }
                      ]
}