variable "project_env" {
  description = "Project environment"
  type        = string
}

variable "project_name"{
  description = "Project name"
  type        = string
}

variable "gcp_project" {
  description = "GCP Project"
  type        = string
}

variable "gcp_log_retention_days" {
  description = "GCP Log Retention"
  type        = number
}

variable "k8s_cluster_name" {
  description = "K8s Cluster Name"
  type        = string
}

variable "service_namespace" {
  description = "Javelin Deployment namespace"
  type        = string
}