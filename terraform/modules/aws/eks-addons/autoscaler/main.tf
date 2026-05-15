########## IAM ##########
data "aws_iam_policy_document" "kubernetes_cluster_autoscaler" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes",
      "eks:DescribeNodegroup"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "kubernetes_cluster_autoscaler" {
  depends_on  = [var.mod_dependency]
  name        = "${var.k8s_cluster_name}-cluster-autoscaler"
  path        = "/"
  description = "Policy for cluster autoscaler service"
  policy      = data.aws_iam_policy_document.kubernetes_cluster_autoscaler.json
}

data "aws_iam_policy_document" "kubernetes_cluster_autoscaler_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.eks_cluster_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_cluster_oidc_provider, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "kubernetes_cluster_autoscaler" {
  name               = "${var.k8s_cluster_name}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.kubernetes_cluster_autoscaler_assume.json
}

resource "aws_iam_role_policy_attachment" "kubernetes_cluster_autoscaler" {
  role       = aws_iam_role.kubernetes_cluster_autoscaler.name
  policy_arn = aws_iam_policy.kubernetes_cluster_autoscaler.arn
}

########## Kubernetes_Namespace ##########
resource "kubernetes_namespace" "deploy_namespace" {
  depends_on = [var.mod_dependency]
  metadata {
    name = var.namespace
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
resource "helm_release" "cluster_autoscaler" {
  depends_on = [
    kubernetes_namespace.deploy_namespace,
    var.mod_dependency
  ]
  name             = "cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = var.helm_version
  namespace        = var.namespace
  force_update     = false
  create_namespace = false
  values = [templatefile("../../../../../config/aws/helm/cluster-autoscaler-values.yml", {
    k8s_cluster_name     = var.k8s_cluster_name
    aws_region           = var.region
    service_account_name = var.service_account_name
  })]
  set = [
    {
      name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.kubernetes_cluster_autoscaler.arn
    }
  ]
}
