variable "project_env" {
  description = "Environment of deployment"
  type        = string
}

variable "project_name" {
  description = "Environment of deployment"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "vpc_name" {
  description = "GCP VPC Name"
  type        = string
}

variable "vpc_id" {
  description = "GCP VPC ID"
  type        = string
}

variable "gcp_project_number" {
  description = "GCP Project number"
  type        = string
}

variable "private_subnet_id" {
  description = "Private Subnet ID"
  type        = string
}

variable "svc_network_cidr_block" {
  description = "Service Network CIDR"
  type        = string
}

variable "redis_subnet_cidr" {
  description = "Redis subnet cidr"
  type        = string
}

variable "private_subnet_cidr" {
  description = "private subnet cidr"
  type        = string
}

variable "public_subnet_cidr" {
  description = "public subnet cidr"
  type        = string
}

variable "gke_authorized_networks" {
  description = "Public CIDR IPs for GKE Access"
  type        = list(object({
                  name      = string
                  cidr      = string
                }))
}

variable "gcp_project" {
  description = "GCP Project"
  type        = string
}

variable "gke_min_master_version" {
  description = "GKE Min master version"
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

variable "gke_demand_node_pool_enable" {
  description = "Enable on_demand node pool"
  type        = bool
  default     = false
}

variable "gke_demand_node_machine_type" {
  description = "GKE on_demand node pool machine type"
  type        = string
  default     = "e2-standard-4"
}

variable "gke_demand_node_min_size" {
  description = "GKE on_demand node pool min size"
  type        = number
  default     = 1
}

variable "gke_demand_node_max_size" {
  description = "GKE on_demand node pool max size"
  type        = number
  default     = 3
}

variable "gke_preemptible_node_pool_enable" {
  description = "Enable preemptible node pool"
  type        = bool
  default     = false
}

variable "gke_preemptible_node_machine_type" {
  description = "GKE preemptible node pool machine type"
  type        = string
  default     = "e2-standard-4"
}

variable "gke_preemptible_node_min_size" {
  description = "GKE preemptible node pool min size"
  type        = number
  default     = 1
}

variable "gke_preemptible_node_max_size" {
  description = "GKE preemptible node pool max size"
  type        = number
  default     = 3
}

variable "custom_egress_port_list" {
  description = "Custom Egress port list for enabling outbound connectivity"
  type        = list(string)
}