variable "project_name" {
  description = "Project name"
  type        = string
}

variable "project_env" {
  description = "Environment stage"
  type        = string
}

variable "storage_classname" {
  description = "Javelin StorageClass"
  type        = string
}

variable "storage_provisioner" {
  description = "Javelin Storage provisioner"
  type        = string
  default     = "pd.csi.storage.gke.io"
}

variable "storage_type" {
  description = "Javelin Storage Type"
  type        = string
  default     = "pd-ssd"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "kms_key_id" {
  description = "KMS Encryption Key ID"
  type        = string
}