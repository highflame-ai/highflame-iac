variable "project_name" {
  description = "Project name"
  type        = string
}

variable "registry_server" {
  description = "Docker Registry Name"
  type        = string
}

variable "registry_username" {
  description = "Docker Registry Username"
  type        = string
}

variable "registry_password" {
  type        = string
  description = "Docker Registry Password"
}

variable "registry_email" {
  description = "Docker Registry Email"
  type        = string
}

variable "secret_namespace_list" {
  description = "Registry Secret available Namespace"
  type        = list(string)
}