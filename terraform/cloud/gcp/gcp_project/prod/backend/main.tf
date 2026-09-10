resource "google_storage_bucket" "backend" {
  count                       = terraform.workspace == "default" ? 1 : 0

  name                        = var.bucket
  location                    = var.region
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}