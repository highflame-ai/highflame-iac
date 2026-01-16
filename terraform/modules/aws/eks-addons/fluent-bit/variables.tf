variable "project_name" {
  description = "Project name"
  type        = string
}

variable "project_env" {
  description = "Environment stage"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type = string
}

variable "namespace" {
  description = "Namespace for the deployment"
  type        = string
  default     = "fluent-bit"
}

variable "helm_version" {
  description = "Helm Chart Version"
  type        = string
  default     = "0.46.2"
}

variable "k8s_cluster_name" {
  type        = string
  description = "K8s Cluster Name"
}

variable "service_namespace" {
  description = "Highflame Deployment namespace"
  type        = string
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