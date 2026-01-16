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
  description = "Grafana Domain Name"
  type        = string
}

variable "grafana_subpath" {
  description = "Grafana subpath"
  type        = string
  default     = "grafana"
}

variable "public_subnet_ids" {
  description = "Public subnet ids"
  type        = list(string)
  default     = [ "" ]
}

variable "acm_certificate_arn" {
  description = "ACM certificate arn"
  type        = string
  default     = ""
}

variable "k8s_cluster_name" {
  description = "K8s cluster name"
  type        = string
  default     = ""
}

variable "alb_security_group_ids" {
  description = "ALB Security Group IDs"
  type        = string
  default     = ""
}