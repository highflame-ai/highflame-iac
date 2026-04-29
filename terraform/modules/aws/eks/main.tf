########## Locals ##########
locals {
  cluster_name                  = join("-", [var.project_name, var.project_env, "eks"])
  tags                          = merge(var.common_tags,
                                      {
                                        EKSCluster = local.cluster_name
                                      })
}

resource "random_id" "random" {
  byte_length                   = 2
}

########## EKS_Cluster ##########
module "eks_cluster" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "21.1.0"

  name                                     = local.cluster_name
  kubernetes_version                       = var.eks_cluster_version
  vpc_id                                   = var.vpc_id
  subnet_ids                               = var.private_subnet_ids
  endpoint_private_access                  = true
  endpoint_public_access                   = true
  endpoint_public_access_cidrs             = [ var.devops_public_cidr ]
  create_cloudwatch_log_group              = true
  enable_irsa                              = true
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  create_security_group                    = false
  create_node_security_group               = false
  security_group_id                        = var.eks_cluster_sg_id
  node_security_group_id                   = var.eks_nodegroup_sg_id

  cloudwatch_log_group_retention_in_days   = var.eks_cloudwatch_retention
  enabled_log_types                        = var.eks_enabled_log_types

  addons_timeouts = {
    create = "15m"
    update = "15m"
    delete = "15m"
  }

  tags = merge(local.tags)
}

########## KMS ##########
resource "aws_kms_key" "eks_kms" {
  description                   = "KMS key for encrypt/decrypt operations"
  deletion_window_in_days       = 10
  enable_key_rotation           = false
}

resource "aws_kms_alias" "eks_kms" {
  name                          = "alias/${local.cluster_name}-${random_id.random.hex}"
  target_key_id                 = aws_kms_key.eks_kms.key_id
}

data "aws_iam_policy_document" "eks_kms" {
  statement {
    effect                      = "Allow"
    resources                   = [ aws_kms_key.eks_kms.arn ]
    actions                     = [ "kms:*" ]

    principals {
      type                      = "AWS"
      identifiers               = [ "arn:aws:iam::${var.aws_account_id}:root" ]
    }
  }

  statement {
    effect                      = "Allow"
    resources                   = [ aws_kms_key.eks_kms.arn ]
    actions                     = [
                                    "kms:Encrypt",
                                    "kms:Decrypt",
                                    "kms:GenerateDataKey*",
                                    "kms:ReEncrypt*",
                                    "kms:DescribeKey"
                                  ]

    principals {
      type                      = "AWS"
      identifiers               = [ "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling" ]
    }

    condition {
      test                      = "StringEquals"
      variable                  = "kms:CallerAccount"
      values                    = [ "${var.aws_account_id}" ] 
    }
  }

  statement {
    effect                      = "Allow"
    resources                   = [ aws_kms_key.eks_kms.arn ]
    actions                     = [
                                    "kms:CreateGrant"
                                  ]

    principals {
      type                      = "AWS"
      identifiers               = [ "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling" ]
    }

    condition {
      test                      = "StringEquals"
      variable                  = "kms:CallerAccount"
      values                    = [ "${var.aws_account_id}" ] 
    }

    condition {
      test                      = "Bool"
      variable                  = "kms:GrantIsForAWSResource"
      values                    = [ true ] 
    }
  }

  statement {
    effect                      = "Allow"
    resources                   = [ aws_kms_key.eks_kms.arn ]
    actions                     = [
                                    "kms:Encrypt",
                                    "kms:Decrypt",
                                    "kms:ReEncrypt*",
                                    "kms:GenerateDataKey*",
                                    "kms:CreateGrant",
                                    "kms:DescribeKey"
                                  ]

    principals {
      type                      = "AWS"
      identifiers               = [ "*" ]
    }

    condition {
      test                      = "StringEquals"
      variable                  = "kms:CallerAccount"
      values                    = [ "${var.aws_account_id}" ] 
    }

    condition {
      test                      = "StringEquals"
      variable                  = "kms:ViaService"
      values                    = [ "ec2.${var.region}.amazonaws.com" ] 
    }
  }
}

resource "aws_kms_key_policy" "eks_kms" {
  key_id                        = aws_kms_key.eks_kms.key_id
  policy                        = data.aws_iam_policy_document.eks_kms.json
}

########## EKS_Addon ##########
data "aws_eks_addon_version" "default_version" {
  for_each                    = { for addon in var.addons : addon.name => addon }
  addon_name                  = each.value.name
  kubernetes_version          = module.eks_cluster.cluster_version
}

resource "aws_eks_addon" "eks_cluster_addons" {
  depends_on                  = [ data.aws_eks_addon_version.default_version ]
  for_each                    = { for addon in var.addons : addon.name => addon }
  cluster_name                = module.eks_cluster.cluster_name
  addon_name                  = each.value.name
  # addon_version               = each.value.version
  addon_version               = data.aws_eks_addon_version.default_version[each.key].version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = merge(local.tags)
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = module.eks_cluster.cluster_name
}