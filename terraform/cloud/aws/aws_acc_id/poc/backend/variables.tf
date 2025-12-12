variable "bucket" {
  description = "StateFile Backend S3 Name"
  type        = string
}

variable "region" {
  description = "Project region"
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

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}