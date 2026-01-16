variable "project_name" {
  description = "Project name"
  type        = string
}

variable "project_env" {
  description = "Environment Name"
  type        = string
}

variable "helm_version" {
  description = "Helm Chart Version"
  type        = string
  default     = "8.3.6"
}

variable "namespace" {
  description = "Namespace for the deployment"
  type        = string
}

variable "storage_classname" {
  description = "Highflame StorageClass"
  type        = string
}

variable "grafana_disk_size" {
  description = "Grafana Disk size"
  type        = string
}

variable "prometheus_url" {
  description = "Prometheus URL"
  type        = string
  default     = "http://javelin-prometheus-server"
}

variable "grafana_domain" {
  description = "Grafana domain"
  type        = string
}

variable "grafana_subpath" {
  description = "Grafana subpath"
  type        = string
  default     = "grafana"
}

variable "grafana_username" {
  description = "Grafana Username"
  type        = string
  default     = "javelin_admin"
}