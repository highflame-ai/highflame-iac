########## Locals ##########
locals {
  kms_prefix              = join("-", ([ var.project_name, var.project_env ]))
}

resource "random_id" "random" {
  byte_length             = 2
}

########## KMS ##########
data "aws_iam_policy_document" "svc_kms" {
  statement {
    effect                = "Allow"
    resources             = [ "*" ]
    actions               = [ "kms:*" ]

    principals {
      type                = "AWS"
      identifiers         = [ "arn:aws:iam::${var.aws_account_id}:root" ]
    }
  }

  statement {
    effect                = "Allow"
    resources             = [ "*" ]

    actions               = [
                              "kms:Encrypt",
                              "kms:Decrypt",
                              "kms:GenerateDataKey*",
                              "kms:DescribeKey"
                            ]

    principals {
      type                = "AWS"
      identifiers         = [ var.svc_iam_role_arn ]
    }
  }
}

resource "aws_kms_key" "svc_kms" {
  description             = "KMS key for encrypt/decrypt operations"
  deletion_window_in_days = 10
  enable_key_rotation     = false
  policy                  = data.aws_iam_policy_document.svc_kms.json
}

resource "aws_kms_alias" "svc_kms" {
  name                    = "alias/${local.kms_prefix}-${random_id.random.hex}"
  target_key_id           = aws_kms_key.svc_kms.key_id
}