variable "bucket" {
  description = "StateFile Backend S3 Name"
  type        = string
}

variable "gcp_project" {
  description = "GCP Project"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type = string
}

variable "default_zone" {
  description = "GCP Default Zone"
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

variable "enable_apis" {
  description = "enable apis"
  type        = bool
}

variable "enable_binary_authorization" {
  description = "enable binary authorization"
  type        = bool
}

variable "enable_security_policies" {
  description = "enable security policies"
  type        = bool
}
variable "enable_ssl_policies" {
  description = "enable ssl policies"
  type        = bool
}

variable "enable_vpc" {
  description = "enable vpc"
  type        = bool
}

variable "enable_svc_network" {
  description = "enable svc network"
  type        = bool
}

variable "enable_postgres" {
  description = "enable postgres"
  type        = bool
}

variable "enable_redis" {
  description = "enable redis"
  type        = bool
}

variable "enable_gke" {
  description = "enable gke"
  type        = bool
}

variable "enable_gcp_logs" {
  description = "enable gcp logs"
  type        = bool
}

variable "enable_svc_iam" {
  description = "enable javelin service account"
  type        = bool
}

variable "gcp_api_list" {
  description = "GCP API list"
  type        = list(string)
}

variable "private_service_cidr" {
  description = "PSA cidr"
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

variable "redis_subnet_cidr" {
  description = "Redis subnet cidr"
  type        = string
}

variable "db_tier" {
  description = "GCP db tier"
  type        = string
}

variable "db_allocated_storage" {
  description = "GCP db storage"
  type        = string
  default     = "50"
}

variable "db_availability_type" {
  description = "GCP db availability type"
  type        = string
  default     = "ZONAL"
}

variable "redis_memory_size" {
  description = "Redis memory size"
  type        = number
}

variable "gke_min_master_version" {
  description = "GKE Min master version"
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

variable "gcp_log_retention_days" {
  description = "GCP Log Retention"
  type        = number
}

variable "service_namespace" {
  description = "Javelin Deployment namespace"
  type        = string
}

variable "workload_identity" {
  description = "workload identity map of namespace and ksa"
  type = list(object({
    namespace      = string
    serviceaccount = string
  }))
}

variable "svc_sa_role_list" {
  description = "Javelin Service account role list"
  type        = list(string)
}

variable "custom_egress_port_list" {
  description = "Custom Egress port list for enabling outbound connectivity"
  type        = list(string)
}

variable "lb_ssl_policy" {
  description = "Load balancer SSL policy"
  type        = string
}

variable "create_bucket_list" {
  description = "GCS bucket list for create"
  type        = list(object({
                              name              = string
                              region            = string
                              storage_class     = string
                            }))
  default     = []
}