locals {
  yaml_data      = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: ${var.cert_acme_email} # Update to yours
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: "${var.project_name}-${var.project_env}-ssl-privatekey"
    # Enable the HTTP-01 challenge provider
    solvers:
      - http01:
          ingress:
            class: azure/application-gateway
      - http01:
          ingress:
            ingressTemplate:
              metadata:
                annotations:
                  kubernetes.io/ingress.class: azure/application-gateway
YAML
}

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

########## Helm_Install ##########
resource "helm_release" "cert_manager" {
  depends_on       = [ kubernetes_namespace.deploy_namespace ]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.helm_version
  force_update     = false
  namespace        = var.namespace
  create_namespace = false
  values = [templatefile("../../../../../config/azure/helm/cert-manager-values.yml", {
    namespace = var.namespace
  })]
}

########## K8s ##########
# resource "kubernetes_manifest" "cluster_issuer" {
#   depends_on = [ helm_release.cert_manager ]
#   manifest   = yamldecode(local.yaml_data)
# }

resource "kubectl_manifest" "cluster_issuer" {
  depends_on = [ helm_release.cert_manager ]
  yaml_body  = local.yaml_data
}