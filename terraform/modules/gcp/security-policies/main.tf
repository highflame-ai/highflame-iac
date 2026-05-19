########## Locals ##########
locals {
  security_policy_prefix   = join("-", ([ var.project_name, var.project_env ]))
}

########## security_policy ##########
resource "google_compute_security_policy" "security_policy" {
  name          = "${local.security_policy_prefix}-security-policy"
  description   = "Policy for ${local.security_policy_prefix}"
  project       = var.gcp_project

  rule {
    action      = "allow"
    priority    = "2147483647"
    description = "default rule"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }

    header_action {
      # request_headers_to_adds {
      #   header_name  = "Content-Security-Policy"
      #   header_value = "default-src self"
      # }

      request_headers_to_adds {
        header_name  = "X-Frame-Options"
        header_value = "DENY"
      }

      # request_headers_to_adds {
      #   header_name  = "Access-Control-Allow-Origin"
      #   header_value = "${var.allow_origins}"
      # }

      # request_headers_to_adds {
      #   header_name  = "X-Content-Type-Options"
      #   header_value = "nosniff"
      # }

      # request_headers_to_adds {
      #   header_name  = "Strict-Transport-Security"
      #   header_value = "max-age=31536000"
      # }

      # request_headers_to_adds {
      #   header_name  = "X-XSS-Protection"
      #   header_value = "1; mode=block"
      # }
    }
  }
}