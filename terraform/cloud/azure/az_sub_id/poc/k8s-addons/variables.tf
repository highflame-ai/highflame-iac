variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "project_env" {
  description = "Project Env"
  type        = string
}

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

variable "location" {
  description = "Project Location"
  type        = string
}

variable "local_kube_config" {
  description = "kube config for kubernetes access from local"
  type        = string
  default     = ""
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

variable "enable_cert_manager" {
  description = "enable cert manager"
  type        = bool
}

variable "storage_classname" {
  description = "Highflame StorageClass"
  type        = string
  default     = "highflame-storageclass"
}

variable "service_namespace" {
  description = "Highflame Deployment namespace"
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

variable "registry_password" {
  type        = string
  description = "Docker Registry Password"
}

variable "registry_email" {
  description = "Docker Registry Email"
  type        = string
  default     = "username@example.com"
}

variable "cert_acme_email" {
  description = "email for ACME Registration"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}