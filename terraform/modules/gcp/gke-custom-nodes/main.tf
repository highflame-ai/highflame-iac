########## GKE_Node_Pool ##########
resource "google_container_node_pool" "gke_node_pool" {
  for_each                              = { for nodes in var.gke_nodes_properties : nodes.name => nodes }

  name                                  = each.value.name
  cluster                               = var.cluster_name
  location                              = var.cluster_location
  node_count                            = each.value.gke_node_min_size
  node_locations                        = each.value.node_locations
  version                               = var.gke_cluster_version

  network_config {
    enable_private_nodes                = true
  }

  node_config {
    preemptible                         = each.value.preemptible_node
    boot_disk_kms_key                   = var.kms_key
    machine_type                        = each.value.gke_node_machine_type
    service_account                     = var.gke_service_account
    tags                                = [ "gke-node", "${each.value.gke_node_capacity_type}-node" ]
    labels                              = {
                                            "kube/nodegroup"        = "${each.value.name}"
                                            "kube/nodetype"         = "${each.value.gke_node_capacity_type}"
                                            "kube/project_env"      = "${var.project_env}"
                                            "kube/project_name"     = "${var.project_name}"
                                          }

    oauth_scopes                        = [
                                            "https://www.googleapis.com/auth/cloud-platform"
                                          ]

    workload_metadata_config {
      mode                              = "GKE_METADATA"
    }

    resource_labels                     = {
                                            goog-gke-node-pool-provisioning-model = each.value.gke_node_capacity_type
                                          }

    kubelet_config {
      cpu_manager_policy                = ""
      cpu_cfs_quota                     = false
      pod_pids_limit                    = 1024
    }

    guest_accelerator {
      type                              = each.value.gke_accelerator_type # Available options: nvidia-tesla-t4, nvidia-a100, nvidia-v100, nvidia-p100
      count                             = each.value.gke_accelerator_count
    }

    metadata = {
      "install-nvidia-driver"           = each.value.gke_gpu_enable
      "disable-legacy-endpoints"        = "true"
    }

    disk_size_gb                        = var.gke_node_disk_size
    disk_type                           = var.gke_node_disk_type
  }

  autoscaling {
    min_node_count                      = each.value.gke_node_min_size
    max_node_count                      = each.value.gke_node_max_size
  }

  management {
    auto_upgrade                        = true
    auto_repair                         = true
  }

  upgrade_settings {
    max_surge                           = 1
    max_unavailable                     = 0
  }

  timeouts {
    create                              = "30m"
    update                              = "30m"
    delete                              = "30m"
  }
}