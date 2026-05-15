variable "project_env" {
  description = "Project environment"
  type        = string
}

variable "project_name" {
  description = "Project environment"
  type        = string
}

variable "gcp_project" {
  description = "GCP Project"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "db_version" {
  description = "Database version"
  type        = string
  default     = "POSTGRES_17"
}

variable "db_tier" {
  description = "Database tier"
  type        = string
}

variable "db_availability_type" {
  description = "Database availability type"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "javelin_data"
}

variable "db_user" {
  description = "Postgres username"
  type        = string
  default     = "javelin"
}

variable "db_allocated_storage" {
  description = "Allocated Storage"
  type        = number
}

variable "backup_start_time" {
  description = "backup start time"
  type        = string
  default     = "05:30"
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "sql_authorized_networks" {
  description = "Public CIDR IPs for SQL Access"
  type        = list(object({
                  name      = string
                  cidr      = string
                }))
  default     = []
}