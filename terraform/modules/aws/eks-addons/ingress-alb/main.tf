########## Locals ##########
locals {
  role_name                = join("-", ([var.project_name, var.project_env, "ingress-alb"]))
}

########## Kubernetes_Namespace ##########
resource "kubernetes_namespace" "deploy_namespace" {
  metadata {
    name          = var.namespace
    annotations   = {
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

########## IAM_Account_Role ##########
module "ingress_alb_role" {
  depends_on                    = [ kubernetes_namespace.deploy_namespace ]
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version                       = "6.1.1"

  name                          = local.role_name
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
    provider_arn               = var.eks_cluster_oidc_provider_arn
    namespace_service_accounts = ["${var.namespace}:${var.k8s_service_account}"]
    }
  }
}

########## Kubernetes_Service_Account ##########
resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = var.k8s_service_account
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"      = "${var.k8s_service_account}"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.ingress_alb_role.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

########## Helm_Install ##########
resource "helm_release" "ingress_alb" {
  depends_on        = [ 
    kubernetes_service_account.service_account,
    var.mod_dependency
  ]
  name              = "aws-load-balancer-controller"
  repository        = "https://aws.github.io/eks-charts"
  chart             = "aws-load-balancer-controller"
  version           = var.helm_version
  namespace         = var.namespace
  force_update      = false
  create_namespace  = false
  values = [templatefile("../../../../../config/aws/${var.project_env}/helm/ingress-alb-values.yml", {
    k8s_cluster_name        = var.k8s_cluster_name
    ingress_replicas        = var.ingress_replicas
    k8s_service_account     = var.k8s_service_account
  })]
}

########## Helm_Install_Dummy_ingress ##########
resource "helm_release" "dummy_ingress" {
  depends_on        = [ helm_release.ingress_alb ]
  name             = "dummy-ingress"
  repository       = "https://highflame-ai.github.io/charts"
  chart            = "javelin-ingress"
  version          = var.javelin_ingress_helm_version
  force_update     = false
  namespace        = var.namespace
  create_namespace = false
  values = [
    templatefile("../../../../../config/aws/${var.project_env}/helm/dummy-ingress-values.yml", {
      public_subnet_ids       = join(", ", var.public_subnet_ids)
      acm_certificate_arn     = var.acm_certificate_arn
      k8s_cluster_name        = var.k8s_cluster_name
      alb_security_group_ids  = var.alb_security_group_ids
    })
  ]
}