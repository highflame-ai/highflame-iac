########## Locals ##########
locals {
  iam_prefix                    = join("-", ([var.project_name, var.project_env]))
}

########## IAM_KMS_Policy ##########
data "aws_iam_policy_document" "kms_access" {
  statement {
    effect                      = "Allow"
    resources                   = [ "*" ]
    actions                     = [
                                    "kms:Encrypt",
                                    "kms:Decrypt",
                                    "kms:GenerateDataKey*",
                                    "kms:ReEncrypt*",
                                    "kms:DescribeKey"
                                  ]
  }
}

resource "aws_iam_policy" "kms_access" {
  name                          = "${local.iam_prefix}-kms-access-policy"
  path                          = "/"
  description                   = "Policy for acessing the kms"
  policy                        = data.aws_iam_policy_document.kms_access.json
}

########## IAM_Bucket_Policy ##########
data "aws_iam_policy_document" "bucket_access" {
  for_each                      = toset(var.svc_bucket_list)
  statement {
    actions                     = [
                                    "s3:*"
                                  ]
    resources                   = [
                                    "arn:aws:s3:::${each.value}/*",
                                    "arn:aws:s3:::${each.value}"
                                  ]
    effect                      = "Allow"
  }
}

resource "aws_iam_policy" "bucket_access" {
  for_each                      = toset(var.svc_bucket_list)
  name                          = "${local.iam_prefix}-s3-access-policy-for-${each.value}"
  path                          = "/"
  description                   = "Policy for acessing the s3 bucket ${each.value}"
  policy                        = data.aws_iam_policy_document.bucket_access[each.value].json
}

########## IAM_Policy ##########
resource "aws_iam_role" "svc_role" {
  name                          = "${local.iam_prefix}-app-role"

  assume_role_policy            = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${var.eks_cluster_oidc_provider_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "${var.eks_cluster_oidc_provider}:sub": "system:serviceaccount:*",
                    "${var.eks_cluster_oidc_provider}:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
EOF
}

########## Locals ##########
locals {
  svc_iam_policy_map            = merge(
                                    { for arn in var.svc_iam_policy_list : element(split("/", arn), length(split("/", arn)) - 1) => arn },
                                    {
                                      "kms"         = aws_iam_policy.kms_access.arn
                                    },
                                    { for bucket in var.svc_bucket_list : "bucket_${bucket}" => aws_iam_policy.bucket_access[bucket].arn }
                                  )
}


resource "aws_iam_role_policy_attachment" "iam_policies" {
  for_each                      = local.svc_iam_policy_map

  role                          = aws_iam_role.svc_role.name
  policy_arn                    = each.value
}