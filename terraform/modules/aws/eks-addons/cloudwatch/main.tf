########## Data_Source ##########
data "aws_eks_cluster" "eks_cluster" {
  name = var.k8s_cluster_name
}

########## IAM ##########
resource "aws_iam_role" "aws_cloudwatch" {
  name               = "${var.k8s_cluster_name}-aws-cloudwatch"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.aws_account_id}:oidc-provider/${split("//", "${data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer}")[1]}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${split("//", "${data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer}")[1]}:aud": "sts.amazonaws.com",
          "${split("//", "${data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer}")[1]}:sub": "system:serviceaccount:aws-cloudwatch:aws-cloudwatch"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws_cloudwatch_CloudWatchFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.aws_cloudwatch.name
}

resource "aws_iam_role_policy_attachment" "aws_cloudwatch_AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.aws_cloudwatch.name
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

########## Helm_Install_CloudWatch ##########
resource "helm_release" "aws_cloudwatch_metrics" {
  # Comment the below variable, 'count', when redeploying the resource...
  # count = 0
  depends_on       = [ kubernetes_namespace.deploy_namespace ]
  name             = "aws-cloudwatch-metrics"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-cloudwatch-metrics"
  version          = var.helm_version
  force_update     = false
  namespace        = var.namespace
  create_namespace = false
  values = [templatefile("../../../../../config/aws/helm/cloudwatch-metrics-values.yml", {
    k8s_cluster_name        = var.k8s_cluster_name
  })]
  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.aws_cloudwatch.arn
    }
  ]
}