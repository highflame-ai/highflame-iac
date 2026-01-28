variable "pg_db_list" {
  description = "List of Database names"
  type        = list(string)
}

variable "pg_extensions" {
  description = "List of extensions and its databases"
  type = list(object({
    name         = string
    database     = string
  }))
}