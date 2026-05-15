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

variable "allow_origins" {
  description = "Domains for allow origins"
  type        = string
  default     = "*"
}