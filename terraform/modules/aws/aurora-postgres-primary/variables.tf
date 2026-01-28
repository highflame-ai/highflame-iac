variable "project_env" {
  description = "Project environment"
  type        = string
}

variable "project_name" {
  description = "Project environment"
  type        = string
}

variable "engine" {
  description = "Aurora engine"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Aurora engine version"
  type        = string
  default     = "16.8"
}

variable "instance_db_class" {
  description = "Aurora instance class"
  type        = string
}

variable "db_name" {
  description = "Aurora name"
  type        = string
  default     = "javelin_data"
}

variable "db_user" {
  description = "Postgres username"
  type        = string
  default     = "highflame"
}

variable "auto_minor_version_upgrade" {
  default     = false
  type        = bool
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:03:00-sun:05:00"
}

variable "backup_window" {
  description = "Backup window"
  type        = string
  default     = "01:00-02:30"
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot"
  type        = bool
  default     = false
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshots"
  type        = bool
  default     = true
}

variable "psql_port" {
  description = "PSQL Port"
  type        = number
  default     = 5432
}

variable "aurora_storage_type" {
  description = "Storage Type"
  type        = string
  default     = "aurora-iopt1"
}

variable "performance_insights_retention_period" {
  description = "Performance Insight Logs Retention"
  type        = number
  default     = 7
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insight"
  type        = bool
  default     = false
}

variable "secret_id" {
  description = "Secret ID"
  type        = string
}

variable "subnet_grp" {
  description = "subnet group ID"
  type        = string
}

variable "cluster_parameter_grp" {
  description = "Cluster parameter group ID"
  type        = string
}

variable "db_parameter_grp" {
  description = "DB parameter group ID"
  type        = string
}

variable "security_grp" {
  description = "security group ID"
  type        = string
}

variable "kms_key_id" {
  description = "KMS Key ID"
  type        = string
}