########## Locals ##########
locals {
    aurora_prefix                      = join("-", ([ var.project_name, var.project_env ]))
}

resource "random_id" "random" {
  byte_length                          = 2
}

########## Cluster_Parameter_Group ##########
resource "aws_rds_cluster_parameter_group" "aurora_postgres" {
  name                                 = "${local.aurora_prefix}-${var.family}-cluster-pg-grp"
  family                               = var.family

  parameter {
    name                               = "rds.force_ssl"
    value                              = "1"
  }

  parameter {
    name                               = "ssl"
    value                              = "1"
    apply_method                       = "pending-reboot"
  }

  parameter {
    name                               = "log_min_duration_statement"
    value                              = "100"
  }
}

########## DB_Parameter_Group ##########
resource "aws_db_parameter_group" "aurora_postgres" {
  name                                 = "${local.aurora_prefix}-${var.family}-db-pg-grp"
  family                               = var.family

  parameter {
    name                               = "log_min_duration_statement"
    value                              = "100"
  }
}

########## Subnet_Group ##########
resource "aws_db_subnet_group" "aurora_postgres" {
  name                                 = "${local.aurora_prefix}-aurora-postgres-subnet-grp"
  subnet_ids                           = var.private_subnet_ids
}

########## Security_Group ##########
resource "aws_security_group" "aurora_postgres" {
  vpc_id                                = var.vpc_id
  name                                  = "${local.aurora_prefix}-aurora-postgres-sg"
  description                           = "Security Group for Aurora Postgres Traffic"
  tags                                  = {
                                            "Name" = "${local.aurora_prefix}-aurora-postgres-sg"
                                          }
  lifecycle {
    create_before_destroy               = true
  }
}

resource "aws_vpc_security_group_egress_rule" "aurora_internal_egress_rule" {
  ip_protocol                           = "-1"
  cidr_ipv4                             = "${var.vpc_cidr}"
  security_group_id                     = aws_security_group.aurora_postgres.id
  description                           = "terraform - vpc internal egress"
  tags                                  = {
                                            Name = "terraform - vpc internal egress"
                                          }
}

resource "aws_vpc_security_group_egress_rule" "aurora_default_egress_rule" {
  from_port                             = var.sg_egress_from_port
  to_port                               = var.sg_egress_to_port
  ip_protocol                           = var.sg_egress_protocol
  cidr_ipv4                             = "${var.sg_egress_cidr}"
  security_group_id                     = aws_security_group.aurora_postgres.id
  description                           = "terraform - default egress"
  tags                                  = {
                                            Name = "terraform - default egress"
                                          }
}

resource "aws_vpc_security_group_egress_rule" "aurora_default_ipv6_egress_rule" {
  count                                 = var.sg_ipv6_egress_enable == true ? 1 : 0

  from_port                             = var.sg_egress_from_port
  to_port                               = var.sg_egress_to_port
  ip_protocol                           = var.sg_egress_protocol
  cidr_ipv6                             = "${var.sg_ipv6_egress_cidr}"
  security_group_id                     = aws_security_group.aurora_postgres.id
  description                           = "terraform - default ipv6 egress"
  tags                                  = {
                                            Name = "terraform - default ipv6 egress"
                                          }
}

resource "aws_vpc_security_group_ingress_rule" "aurora_rule" {
  from_port                             = var.psql_port
  to_port                               = var.psql_port
  ip_protocol                           = "tcp"
  cidr_ipv4                             = "${var.vpc_cidr}"
  security_group_id                     = aws_security_group.aurora_postgres.id
  description                           = "terraform - psql access from vpc"
  tags                                  = {
                                            Name = "terraform - psql access from vpc"
                                          }
}

########## KMS ##########
resource "aws_kms_key" "aurora_kms" {
  description                           = "KMS key for encrypt/decrypt operations"
  deletion_window_in_days               = 10
  enable_key_rotation                   = false
}

resource "aws_kms_alias" "aurora_kms" {
  name                                  = "alias/${local.aurora_prefix}-aurora-${random_id.random.hex}"
  target_key_id                         = aws_kms_key.aurora_kms.key_id
}

data "aws_iam_policy_document" "aurora_kms" {
  statement {
    effect                              = "Allow"
    resources                           = [ aws_kms_key.aurora_kms.arn ]
    actions                             = [ "kms:*" ]

    principals {
      type                              = "AWS"
      identifiers                       = [ "arn:aws:iam::${var.aws_account_id}:root" ]
    }
  }

  statement {
    effect                              = "Allow"
    resources                           = [ aws_kms_key.aurora_kms.arn ]
    actions                             = [
                                            "kms:Encrypt",
                                            "kms:Decrypt",
                                            "kms:ReEncrypt*",
                                            "kms:GenerateDataKey*",
                                            "kms:CreateGrant",
                                            "kms:DescribeKey"
                                          ]

    principals {
      type                              = "AWS"
      identifiers                       = [ "*" ]
    }

    condition {
      test                              = "StringEquals"
      variable                          = "kms:CallerAccount"
      values                            = [ "${var.aws_account_id}" ] 
    }
  }
}

resource "aws_kms_key_policy" "eks_kms" {
  key_id                                = aws_kms_key.aurora_kms.key_id
  policy                                = data.aws_iam_policy_document.aurora_kms.json
}

########## Secret_Manager ##########
resource "aws_secretsmanager_secret" "aurora_password" {
  name                                  = "${local.aurora_prefix}-aurora-postgres-${random_id.random.hex}"
  description                           = "ManagedBy Terraform"
  recovery_window_in_days               = 30
}