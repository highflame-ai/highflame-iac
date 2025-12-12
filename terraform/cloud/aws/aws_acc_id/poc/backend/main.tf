locals {
  tags                              = merge(var.common_tags,
                                            {
                                              Project       = var.project_name
                                              Environment   = var.project_env
                                            })
}

resource "aws_s3_bucket" "backend" {
  count                             = terraform.workspace == "default" ? 1 : 0

  bucket                            = var.bucket
  lifecycle {
    prevent_destroy                 = true
  }
}

resource "aws_s3_bucket_versioning" "backend" {
  count                             = terraform.workspace == "default" ? 1 : 0

  bucket                            = aws_s3_bucket.backend.0.id
  versioning_configuration {
    status                          = "Enabled"
  }
  lifecycle {
    prevent_destroy                 = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  count                             = terraform.workspace == "default" ? 1 : 0

  bucket                            = aws_s3_bucket.backend.0.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
  lifecycle {
    prevent_destroy                 = true
  }
}