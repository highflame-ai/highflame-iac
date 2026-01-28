########## Locals ##########
locals {
  secret_name              = join("-", ([var.project_name, "registry-secret"]))
}

########## Kubernetes_Secret ##########
resource "kubernetes_secret" "reg_secret" {
  count = length(var.secret_namespace_list)

  metadata {
    name      = local.secret_name
    namespace = var.secret_namespace_list[count.index]
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.registry_username
          "password" = var.registry_password
          "email"    = var.registry_email
          "auth"     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }

  lifecycle {
    ignore_changes = [ data ]
  }
}