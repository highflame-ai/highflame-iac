########## Locals ##########
locals {
    aurora_prefix                      = join("-", ([ var.project_name, var.project_env ]))
}

########## Random_Pass ##########
resource "random_password" "aurora_password" {
  length                               = 16
  special                              = false
}

########## Aurora ##########
resource "aws_rds_global_cluster" "aurora_global" {
  global_cluster_identifier             = "${local.aurora_prefix}-aurora-global"
  deletion_protection                   = true
  database_name                         = var.db_name
  engine_version                        = var.engine_version
  engine                                = var.engine
  storage_encrypted                     = true
}

resource "aws_rds_cluster" "aurora_global" {
  cluster_identifier                    = "${local.aurora_prefix}-aurora-cluster"
  global_cluster_identifier             = aws_rds_global_cluster.aurora_global.id
  engine                                = aws_rds_global_cluster.aurora_global.engine
  engine_version                        = aws_rds_global_cluster.aurora_global.engine_version
  database_name                         = aws_rds_global_cluster.aurora_global.database_name
  db_subnet_group_name                  = var.subnet_grp
  master_username                       = var.db_user
  master_password                       = random_password.aurora_password.result
  storage_type                          = var.aurora_storage_type
  deletion_protection                   = true
  apply_immediately                     = true
  storage_encrypted                     = true
  performance_insights_enabled          = var.performance_insights_enabled
  # performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.kms_key_id
  kms_key_id                            = var.kms_key_id
  vpc_security_group_ids                = [ var.security_grp ]
  db_cluster_parameter_group_name       = var.cluster_parameter_grp
  preferred_maintenance_window          = var.maintenance_window
  preferred_backup_window               = var.backup_window
  backup_retention_period               = var.backup_retention_period
  skip_final_snapshot                   = var.skip_final_snapshot
  final_snapshot_identifier             = "${local.aurora_prefix}-aurora-final"
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports       = [ "postgresql" ]
  port                                  = var.psql_port

  lifecycle {
    ignore_changes                      = [ master_password ]
  }
}

resource "aws_rds_cluster_instance" "aurora_global" {
  identifier                            = "${local.aurora_prefix}-aurora-postgres"
  engine                                = aws_rds_global_cluster.aurora_global.engine
  engine_version                        = aws_rds_global_cluster.aurora_global.engine_version
  cluster_identifier                    = aws_rds_cluster.aurora_global.id
  instance_class                        = var.instance_db_class
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  apply_immediately                     = true
  publicly_accessible                   = false
  db_parameter_group_name               = var.db_parameter_grp
}

########## Secret_Manager_Data ##########
resource "aws_secretsmanager_secret_version" "aurora_password" {
  secret_id                             = var.secret_id
  secret_string                         = <<EOF
  {
    "global_cluster_id" : "${aws_rds_global_cluster.aurora_global.id}",
    "dbname"            : "${aws_rds_global_cluster.aurora_global.database_name}",
    "engine"            : "${aws_rds_global_cluster.aurora_global.engine}",
    "username"          : "${aws_rds_cluster.aurora_global.master_username}",
    "password"          : "${aws_rds_cluster.aurora_global.master_password}",
    "host"              : "${aws_rds_global_cluster.aurora_global.endpoint}",
    "writer"            : "${aws_rds_cluster.aurora_global.endpoint}",
    "reader"            : "${aws_rds_cluster.aurora_global.reader_endpoint}",
    "port"              : "${aws_rds_cluster.aurora_global.port}"
  }
EOF

  lifecycle {
    ignore_changes                      = [ secret_string ]
  }
}