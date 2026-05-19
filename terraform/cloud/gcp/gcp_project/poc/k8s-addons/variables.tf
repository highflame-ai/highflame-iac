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

variable "enable_storageclass" {
  description = "enable StorageClass"
  type        = bool
}

variable "enable_namespace" {
  description = "Enable Namespace Setup"
  type        = bool
}

variable "enable_docker_secret" {
  description = "enable Docker Registry Secrets"
  type        = bool
}

variable "storage_classname" {
  description = "Javelin StorageClass"
  type        = string
  default     = "javelin-storageclass"
}

variable "service_namespace" {
  description = "Javelin Deployment namespace"
  type        = string
}

variable "registry_server" {
  description = "Docker Registry Name"
  type        = string
  default     = "ghcr.io"
}

variable "registry_username" {
  description = "Docker Registry Username"
  type        = string
  default     = "username"
}

variable "registry_email" {
  description = "Docker Registry Email"
  type        = string
  default     = "username@example.com"
}

variable "registry_password" {
  type        = string
  description = "Docker Registry Password"
}