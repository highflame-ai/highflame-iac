variable "project_env" {
  description = "Project environment"
  type        = string
}

variable "project_name"{
  description = "Project name"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "redis_memory_size" {
  description = "Redis memory size"
  type        = number
}

variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = "REDIS_7_0"
}

variable "redis_tier" {
  description = "Cache instance class"
  type        = string
  default = "STANDARD_HA"
}

variable "redis_subnet_cidr" {
  description = "Redis subnet cidr"
  type        = string
}

variable "gcp_project" {
  description = "GCP Project"
  type        = string
}

variable "gcp_project_number" {
  description = "GCP Project number"
  type        = string
}