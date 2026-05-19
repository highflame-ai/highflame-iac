variable "create_bucket_list" {
  description = "GCS bucket list for create"
  type        = list(object({
                              name              = string
                              region            = string
                              storage_class     = string
                            }))
  default     = []
}

variable "gcp_project_number" {
  description = "GCP Project number"
  type        = string
}