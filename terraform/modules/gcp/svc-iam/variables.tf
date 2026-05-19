variable "project_name" {
  description = "Project name"
  type        = string
}

variable "project_env" {
  description = "Environment stage"
  type        = string
}

variable "gcp_project" {
  description = "GCP Project"
  type        = string
}

variable "sa_suffix" {
  description = "Service account name suffix"
  type        = string
  default     = "svc-sa"
}

variable "workload_identity" {
  description = "workload identity map of namespace and ksa"
  type = list(object({
    namespace      = string
    serviceaccount = string
  }))
  default          = []
}

variable "svc_sa_role_list" {
  description = "Service account role list"
  type        = list(string)
}

variable "svc_bucket_list" {
  description = "svc bucket list"
  type        = list(string)
  default     = []
}