variable "project_name" {
  description = "Project name"
  type        = string
}

variable "project_env" {
  description = "Environment stage"
  type        = string
}

variable "helm_version" {
  description = "Helm Chart Version"
  type        = string
  default     = "25.20.1"
}

variable "namespace" {
  description = "Namespace for the deployment"
  type        = string
}

variable "service_namespace" {
  description = "Highflame Deployment namespace"
  type        = string
}

variable "storage_classname" {
  description = "Highflame StorageClass"
  type        = string
}

variable "prometheus_disk_size" {
  description = "Prometheus Disk size"
  type        = string
}