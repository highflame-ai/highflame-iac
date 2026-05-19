########## Locals ##########
locals {
  tag_list                = [for k, v in var.common_tags : "${k}=${v}"]
  tag_spec_map            = zipmap(
                                    [ for i in range(length(local.tag_list)) : "tagSpecification_${i + 1}" ],
                                    local.tag_list
                                  )
  merged_tags             = merge(
                              local.tag_spec_map,
                              {
                                type                      = var.storage_type
                                disk-encryption-kms-key   = var.kms_key_id
                              }
                            )
}

########## StorageClass ##########
resource "kubernetes_storage_class" "storage_class" {
  metadata {
    name                  = var.storage_classname
    annotations           = {
                              "storageclass.kubernetes.io/is-default-class" = "false"
                            }
  }
  allow_volume_expansion  = true
  volume_binding_mode     = "WaitForFirstConsumer"
  storage_provisioner     = var.storage_provisioner
  reclaim_policy          = "Delete"
  parameters              = local.merged_tags
}