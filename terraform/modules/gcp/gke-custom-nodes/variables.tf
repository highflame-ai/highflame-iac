variable "project_name" {
  description = "Project name"
  type        = string
}

variable "project_env" {
  description = "Environment stage"
  type        = string
}

variable "gke_node_disk_size" {
  description = "GKE node disk size"
  type        = number
  default     = 100
}

variable "gke_node_disk_type" {
  description = "GKE node disk type"
  type        = string
  default     = "pd-ssd"
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "cluster_location" {
  description = "Cluster location"
  type        = string
}

variable "kms_key" {
  description = "Encription Key"
  type        = string
}

variable "gke_service_account" {
  description = "gke service account"
  type        = string
}

variable "gke_cluster_version" {
  description = "gke cluster version"
  type        = string
}

variable "gke_nodes_properties" {
  description = "GKE nodes properties"
  type = list(object({
    name                     = string
    node_locations           = list(string)
    preemptible_node         = bool
    gke_gpu_enable           = bool
    gke_accelerator_type     = string
    gke_accelerator_count    = number
    gke_node_capacity_type   = string
    gke_node_machine_type    = string
    gke_node_min_size        = number
    gke_node_max_size        = number
  }))
}