variable "bucket" {
  description = "StateFile Backend S3 Name"
  type        = string
}

variable "region" {
  description = "AWS Region"
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

variable "enable_namespace" {
  description = "Enable Namespace Setup"
  type        = bool
}

variable "enable_docker_secret" {
  description = "enable Docker Registry Secrets"
  type        = bool
}

variable "enable_storageclass" {
  description = "enable StorageClass"
  type        = bool
}

variable "enable_autoscaler" {
  description = "enable AutoScaler"
  type        = bool
}

variable "enable_fluent_bit" {
  description = "enable fluentBit"
  type        = bool
}

variable "enable_ingress_alb_crds" {
  description = "enable ingress alb crds"
  type        = bool
}

variable "enable_ingress_alb" {
  description = "enable ingress alb"
  type        = bool
}

variable "enable_prometheus" {
  description = "enable prometheus"
  type        = bool
}

variable "enable_grafana" {
  description = "enable grafana"
  type        = bool
}

variable "enable_metrics_server" {
  description = "enable metrics server"
  type        = bool
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

variable "ingress_replicas" {
  description = "Number of Replica for Ingress"
  type        = number
  default     = 4
}

variable "cloudwatch_log_retention" {
  description = "CloudWatch Log Retention (For CloudWatch Output)"
  type        = number
}

variable "fluent_output" {
  description = "FluentBit Output"
  type        = string
  default     = "cloudwatch"
}

variable "prometheus_disk_size" {
  description = "Prometheus Disk size"
  type        = string
  default     = "50Gi"
}

variable "storage_classname" {
  description = "Highflame StorageClass"
  type        = string
  default     = "javelin-storageclass"
}

variable "service_namespace" {
  description = "Highflame Deployment namespace"
  type        = string
}

variable "javelin_ingress_helm_version" {
  description = "Helm Chart Version for javelin-ingress"
  type        = string
  default     = "0.0.0-latest"
}

variable "frontend_acm_certificate_arn" {
  description = "ACM Certificate ARN for Frontend"
  type        = string
}

variable "grafana_acm_certificate_arn" {
  description = "ACM Certificate ARN for Grafana"
  type        = string
}

variable "grafana_disk_size" {
  description = "Grafana Disk size"
  type        = string
  default     = "10Gi"
}

variable "grafana_domain" {
  description = "Grafana Domain Name"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}