########## Locals ##########
locals {
  redis_prefix               = join("-", ([ var.project_name, var.project_env ]))
}

resource "random_id" "random" {
  byte_length                = 2
}

########## Security_Group ##########
resource "aws_security_group" "redis_sg" {
  vpc_id                     = var.vpc_id
  name                       = "${local.redis_prefix}-redis-cluster-sg"
  description                = "Security Group for Elastic Cache Redis Traffic"
  tags                       = {
                                "Name" = "${local.redis_prefix}-redis-cluster-sg"
                              }
  lifecycle {
    create_before_destroy    = true
  }
}

resource "aws_vpc_security_group_egress_rule" "redis_internal_egress_rule" {
  ip_protocol                = "-1"
  cidr_ipv4                  = "${var.vpc_cidr}"
  security_group_id          = aws_security_group.redis_sg.id
  description                = "terraform - vpc internal egress"
  tags                       = {
                                Name = "terraform - vpc internal egress"
                              }
}

resource "aws_vpc_security_group_egress_rule" "redis_default_egress_rule" {
  from_port                  = var.sg_egress_from_port
  to_port                    = var.sg_egress_to_port
  ip_protocol                = var.sg_egress_protocol
  cidr_ipv4                  = "${var.sg_egress_cidr}"
  security_group_id          = aws_security_group.redis_sg.id
  description                = "terraform - default egress"
  tags                       = {
                                Name = "terraform - default egress"
                              }
}

resource "aws_vpc_security_group_egress_rule" "redis_default_ipv6_egress_rule" {
  count                      = var.sg_ipv6_egress_enable == true ? 1 : 0

  from_port                  = var.sg_egress_from_port
  to_port                    = var.sg_egress_to_port
  ip_protocol                = var.sg_egress_protocol
  cidr_ipv6                  = "${var.sg_ipv6_egress_cidr}"
  security_group_id          = aws_security_group.redis_sg.id
  description                = "terraform - default ipv6 egress"
  tags                       = {
                                Name = "terraform - default ipv6 egress"
                              }
}

resource "aws_vpc_security_group_ingress_rule" "redis_ingress_rule" {
  from_port                  = var.redis_port
  to_port                    = var.redis_port
  ip_protocol                = "tcp"
  cidr_ipv4                  = "${var.vpc_cidr}"
  security_group_id          = aws_security_group.redis_sg.id
  description                = "terraform - redis access from vpc"
  tags                       = {
                                Name = "terraform - redis access from vpc"
                              }
}

resource "aws_vpc_security_group_ingress_rule" "additional_redis_ingress_rule" {
  for_each                   = toset(var.additional_whitelist_cidr)

  from_port                  = var.redis_port
  to_port                    = var.redis_port
  ip_protocol                = "tcp"
  cidr_ipv4                  = "${each.value}"
  security_group_id          = aws_security_group.redis_sg.id
  description                = "terraform - redis access from ${each.value}"
  tags                       = {
                                Name = "terraform - redis access from ${each.value}"
                              }
}

########## KMS ##########
resource "aws_kms_key" "redis_kms" {
  description                 = "KMS key for encrypt/decrypt operations"
  deletion_window_in_days     = 10
  enable_key_rotation         = false
}

resource "aws_kms_alias" "redis_kms" {
  name                        = "alias/${local.redis_prefix}-redis-cluster-${random_id.random.hex}"
  target_key_id               = aws_kms_key.redis_kms.key_id
}

data "aws_iam_policy_document" "redis_kms" {
  statement {
    effect                    = "Allow"
    resources                 = [ aws_kms_key.redis_kms.arn ]
    actions                   = [ "kms:*" ]

    principals {
      type                    = "AWS"
      identifiers             = [ "arn:aws:iam::${var.aws_account_id}:root" ]
    }
  }

  statement {
    effect                    = "Allow"
    resources                 = [ aws_kms_key.redis_kms.arn ]
    actions                   = [
                                  "kms:Encrypt",
                                  "kms:Decrypt",
                                  "kms:ReEncrypt*",
                                  "kms:GenerateDataKey*",
                                  "kms:CreateGrant",
                                  "kms:DescribeKey"
                                ]

    principals {
      type                   = "AWS"
      identifiers            = [ "*" ]
    }

    condition {
      test                   = "StringEquals"
      variable               = "kms:CallerAccount"
      values                 = [ "${var.aws_account_id}" ] 
    }
  }
}

resource "aws_kms_key_policy" "redis_kms" {
  key_id                     = aws_kms_key.redis_kms.key_id
  policy                     = data.aws_iam_policy_document.redis_kms.json
}

########## Redis_SubnetGroup ##########
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name                       = "${local.redis_prefix}-redis-cluster-subnet-grp"
  subnet_ids                 = var.private_subnet_ids
}

########## Redis_ParameterGroup ##########
resource "aws_elasticache_parameter_group" "redis_params_group" {
  name                       = "${local.redis_prefix}-redis-cluster-pg-grp"
  family                     = var.family
}

########## CloudWatch ##########
resource "aws_cloudwatch_log_group" "redis_log" {
  name                       = "${local.redis_prefix}-redis-cluster-log"
  retention_in_days          = var.redis_cloudwatch_retention
}

########## Random_Pass ##########
resource "random_password" "redis_password" {
  length                     = 16
  special                    = false
}

########## Redis_Cluster ##########
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${local.redis_prefix}-redis-cluster"
  description                = "${local.redis_prefix}-redis-cluster"
  engine                     = var.engine
  node_type                  = var.redis_node_type
  engine_version             = var.engine_version
  apply_immediately          = true
  security_group_ids         = [aws_security_group.redis_sg.id]
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet_group.name
  parameter_group_name       = aws_elasticache_parameter_group.redis_params_group.name
  port                       = var.redis_port
  maintenance_window         = var.maintenance_window
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  cluster_mode               = "disabled"
  num_cache_clusters         = 1
  automatic_failover_enabled = false
  multi_az_enabled           = false
  network_type               = "ipv4"
  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  transit_encryption_mode    = "required"
  kms_key_id                 = aws_kms_key.redis_kms.arn
  auth_token                 = random_password.redis_password.result
  auth_token_update_strategy = "SET"
  log_delivery_configuration {
    destination              = aws_cloudwatch_log_group.redis_log.name
    destination_type         = "cloudwatch-logs"
    log_format               = "json"
    log_type                 = "slow-log"
  }
}