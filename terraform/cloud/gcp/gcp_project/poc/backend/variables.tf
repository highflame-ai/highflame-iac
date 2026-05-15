variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "project_env" {
  description = "Project Env"
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

variable "bucket" {
  description = "StateFile Backend S3 Name"
  type        = string
}