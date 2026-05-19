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

variable "private_subnet_cidr" {
  description = "private subnet inside the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "public subnet inside the VPC"
  type        = string
}