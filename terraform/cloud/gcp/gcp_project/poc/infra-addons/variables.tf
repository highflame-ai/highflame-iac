variable "bucket" {
  description = "StateFile Backend S3 Name"
  type        = string
}

variable "gcp_project" {
  description = "GCP Project"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type = string
}

variable "default_zone" {
  description = "GCP Default Zone"
  type = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "project_env" {
  description = "Project Env"
  type        = string
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