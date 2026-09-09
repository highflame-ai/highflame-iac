variable "az_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "storage_account_name" {
  description = "Storage Account Name"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "project_env" {
  description = "Project Env"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "enable_psql_seeding" {
  description = "enable psql seeding"
  type        = bool
}

variable "pg_db_list" {
  description = "List of Database names"
  type        = list(string)
  default     = []
}

variable "pg_extensions" {
  description = "List of extensions and its databases"
  type        = list(object({
    name         = string
    database     = string
  }))
  default     = []
}