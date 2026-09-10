variable "az_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "storage_account_name" {
  description = "Storage Account Name"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "project_env" {
  description = "Project Env"
  type        = string
}

variable "location" {
  description = "Project Location"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "ad_object_id" {
  description = "ad user or group object id"
  type        = string
  default     = ""
}