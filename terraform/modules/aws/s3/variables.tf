variable "project_name" {
  description = "Project name"
  type        = string
}

variable "project_env" {
  description = "Environment stage"
  type        = string
}

variable "create_bucket_list" {
  description = "Bucket suffix list"
  type        = list(string)
}