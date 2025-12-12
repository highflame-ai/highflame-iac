variable "project_env" {
  description = "Environment of deployment"
  type        = string
}

variable "project_name" {
  description = "Environment of deployment"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "resource_group_name" {
  description = "resource group name"
  type        = string
}

variable "private_subnet_id" {
  description = "private subnet id"
  type        = string
}

variable "db_user" {
  description = "Postgres username"
  type        = string
  default     = "javelin"
}

variable "db_version" {
  description = "Database server version"
  type        = string
  default     = "17"
}

variable "postgres_sku_name" {
  description = "Database server sku"
  type        = string
}

variable "private_dns_zone_id" {
  description = "private dns zone id"
  type        = string
}

variable "backup_retention_days" {
  description = "backup retention days"
  type        = number
  default     = 7
}

variable "des_keyvault_key_id" {
  description = "des keyvault key id"
  type        = string
}

variable "secret_keyvault_id" {
  description = "secret keyvault id"
  type        = string
}

variable "identity_id" {
  description = "identity id"
  type        = string
}

variable "postgres_storage_mb" {
  description = "Postgres allocated storage"
  type        = number
}

variable "postgres_storage_tier" {
  description = "Database storage tier"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "javelin_data"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "enable_delete_lock" {
  description = "enable delete lock"
  type        = bool
}

variable "postgres_server_params" {
  description = "Postgres Server Parameters"
  type = list(object({
    name    = string
    value   = string
  }))
}

variable "tags" {
  description = "tags"
  type        = map(string)
}