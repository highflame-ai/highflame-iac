########## Locals ##########
locals {
  log_prefix                            = join("-", [var.project_name, var.project_env])
}

########## Logging_Bucket ##########
resource "google_logging_project_bucket_config" "log_bucket" {
  project                               = var.gcp_project
  location                              = "global"
  retention_days                        = var.gcp_log_retention_days
  bucket_id                             = "${var.k8s_cluster_name}-service-log"
}

########## Log_Sink ##########
resource "google_logging_project_sink" "log_sink" {
  name                                  = "${local.log_prefix}-log-bucket-sink"
  destination                           = "logging.googleapis.com/${google_logging_project_bucket_config.log_bucket.id}"
  filter                                = "resource.labels.cluster_name=\"${var.k8s_cluster_name}\" AND resource.labels.namespace_name=\"${var.service_namespace}\""
  # unique_writer_identity                = false
}