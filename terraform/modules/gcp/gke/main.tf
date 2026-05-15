########## Locals ##########
locals {
  gke_prefix                            = join("-", [var.project_name, var.project_env])
}

resource "random_id" "random" {
  byte_length                           = 2
}

########## KMS ##########
resource "google_kms_key_ring" "gke_keyring" {
  name                                  = "${local.gke_prefix}-gke-keyring-${random_id.random.hex}"
  location                              = var.region
}

resource "google_kms_crypto_key" "gke_key" {
  name                                  = "${local.gke_prefix}-gke-key-${random_id.random.hex}"
  key_ring                              = google_kms_key_ring.gke_keyring.id
  # rotation_period                       = "2592000s"
  purpose                               = "ENCRYPT_DECRYPT"

  version_template {
    algorithm                           = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level                    = "SOFTWARE"
  }
}

########## GKE_Ingress_Static_IP ##########
resource "google_compute_global_address" "ingress_static_ip" {
  name                                  = "${local.gke_prefix}-ingress-ip"
  address_type                          = "EXTERNAL"
}

########## GKE_Master ##########
resource "google_container_cluster" "gke_cluster" {
  name                                  = "${local.gke_prefix}-gke"
  location                              = var.region
  initial_node_count                    = 1
  remove_default_node_pool              = true
  deletion_protection                   = false
  network                               = var.vpc_id
  subnetwork                            = var.private_subnet_id
  logging_service                       = "logging.googleapis.com/kubernetes"
  monitoring_service                    = "monitoring.googleapis.com/kubernetes"
  min_master_version                    = var.gke_min_master_version
  workload_identity_config {
    workload_pool                       = "${var.gcp_project}.svc.id.goog"
  }

  ip_allocation_policy {
    services_ipv4_cidr_block = "172.21.0.0/16"
    stack_type               = "IPV4"
  }

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.gke_key.id
  }

  # logging_config {
  #   enable_components = [ 
  #     "SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER", "WORKLOADS"
  #   ]
  # }

  # logging_config {
  #   enable_components = [ 
  #     "SYSTEM_COMPONENTS", "WORKLOADS"
  #   ]
  # }

  # monitoring_config {
  #   enable_components = [
  #     "SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER", "STORAGE", "HPA", "POD", "DAEMONSET", "DEPLOYMENT", "STATEFULSET", "KUBELET", "CADVISOR"
  #   ]
  # }

  # release_channel {
  #   channel                             = "STABLE"
  # }

  master_auth {
    client_certificate_config {
      issue_client_certificate          = true
    }
  }

  master_authorized_networks_config {
    # cidr_blocks {
    #     cidr_block                      = "0.0.0.0/0"
    #     display_name                    = "public"
    # }
    dynamic "cidr_blocks" {
      for_each = var.gke_authorized_networks
      content {
        display_name                    = cidr_blocks.value.name
        cidr_block                      = cidr_blocks.value.cidr
      }
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "01:00"
    }
  }

  # network_policy {
  #   enabled                             = false
  #   provider                            = "CALICO"
  # }

  addons_config {
    horizontal_pod_autoscaling {
      disabled                          = false
    }
    http_load_balancing {
      disabled                          = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled                           = true
    }
    network_policy_config {
      disabled                          = true
    }
    gcp_filestore_csi_driver_config {
      enabled                           = false
    }
    gcs_fuse_csi_driver_config {
      enabled                           = false
    }
    dns_cache_config {
      enabled                           = false
    }
    gke_backup_agent_config {
      enabled                           = false
    }
  }

  timeouts {
    create                              = "30m"
    update                              = "30m"
    delete                              = "30m"
  }
}

########## Service_Agent ##########
resource "google_kms_crypto_key_iam_member" "gke_engine_kms_encrypter_decrypter" {
  crypto_key_id                         = google_kms_crypto_key.gke_key.id
  role                                  = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member                                = "serviceAccount:service-${var.gcp_project_number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "gke_engine_kms_viewer" {
  crypto_key_id                         = google_kms_crypto_key.gke_key.id  
  role                                  = "roles/cloudkms.viewer"
  member                                = "serviceAccount:service-${var.gcp_project_number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "compute_engine_kms_encrypter_decrypter" {
  crypto_key_id                         = google_kms_crypto_key.gke_key.id
  role                                  = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member                                = "serviceAccount:service-${var.gcp_project_number}@compute-system.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "compute_engine_kms_viewer" {
  crypto_key_id                         = google_kms_crypto_key.gke_key.id  
  role                                  = "roles/cloudkms.viewer"
  member                                = "serviceAccount:service-${var.gcp_project_number}@compute-system.iam.gserviceaccount.com"
}

########## Service_Account ##########
resource "google_project_iam_custom_role" "gke_role" {
  project                               = var.gcp_project
  role_id                               = "${replace(local.gke_prefix, "-", "_")}_gke_role"
  title                                 = "${replace(local.gke_prefix, "-", "_")}_gke_role"
  description                           = "GKE role with specific permissions"
  permissions                           = [
                                            "logging.logEntries.create",
                                            "logging.logEntries.route",
                                            "monitoring.metricDescriptors.create",
                                            "monitoring.metricDescriptors.get",
                                            "monitoring.metricDescriptors.list",
                                            "monitoring.monitoredResourceDescriptors.get",
                                            "monitoring.monitoredResourceDescriptors.list",
                                            "monitoring.timeSeries.create",
                                            "storage.folders.get",
                                            "storage.folders.list",
                                            "storage.managedFolders.get",
                                            "storage.managedFolders.list",
                                            "storage.objects.get",
                                            "storage.objects.list"
                                          ]
}

resource "google_service_account" "gke_sa" {
  account_id                            = "${local.gke_prefix}-gke-sa"
  display_name                          = "${local.gke_prefix}-gke-sa"
}

resource "google_project_iam_member" "gke_sa_role_binding" {
  project                               = var.gcp_project
  role                                  = google_project_iam_custom_role.gke_role.name
  member                                = "serviceAccount:${google_service_account.gke_sa.email}"
}

########## GKE_Demand_Node_Pool ##########
resource "google_container_node_pool" "demand_node_pool" {
  count                                 = var.gke_demand_node_pool_enable == true ? 1 : 0

  name                                  = "${local.gke_prefix}-demand"
  cluster                               = google_container_cluster.gke_cluster.name
  location                              = google_container_cluster.gke_cluster.location
  node_count                            = var.gke_demand_node_min_size

  network_config {
    enable_private_nodes                = true
  }

  node_config {
    preemptible                         = false
    boot_disk_kms_key                   = google_kms_crypto_key.gke_key.id
    machine_type                        = var.gke_demand_node_machine_type
    service_account                     = google_service_account.gke_sa.email
    tags                                = [ "gke-node", "demand-node" ]
    labels                              = {
                                            "kube/nodetype"         = "demand"
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
                                            goog-gke-node-pool-provisioning-model = "standard"
                                          }

    kubelet_config {
      cpu_manager_policy                = ""
      cpu_cfs_quota                     = false
      pod_pids_limit                    = 1024
    }

    disk_size_gb                        = var.gke_node_disk_size
    disk_type                           = var.gke_node_disk_type
  }

  autoscaling {
    min_node_count                      = var.gke_demand_node_min_size
    max_node_count                      = var.gke_demand_node_max_size
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

########## GKE_Preemptible_Node_Pool ##########
resource "google_container_node_pool" "preemptible_node_pool" {
  count                                 = var.gke_preemptible_node_pool_enable == true ? 1 : 0

  name                                  = "${local.gke_prefix}-preemptible"
  cluster                               = google_container_cluster.gke_cluster.name
  location                              = google_container_cluster.gke_cluster.location
  node_count                            = var.gke_preemptible_node_min_size

  network_config {
    enable_private_nodes                = true
  }

  node_config {
    preemptible                         = true
    boot_disk_kms_key                   = google_kms_crypto_key.gke_key.id
    machine_type                        = var.gke_preemptible_node_machine_type
    service_account                     = google_service_account.gke_sa.email
    tags                                = [ "gke-node", "preemptible-node" ]
    labels                              = {
                                            "kube/nodetype"         = "preemptible"
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
                                            goog-gke-node-pool-provisioning-model = "spot"
                                          }

    kubelet_config {
      cpu_manager_policy                = ""
      cpu_cfs_quota                     = false
      pod_pids_limit                    = 1024
    }

    disk_size_gb                        = var.gke_node_disk_size
    disk_type                           = var.gke_node_disk_type
  }

  autoscaling {
    min_node_count                      = var.gke_preemptible_node_min_size
    max_node_count                      = var.gke_preemptible_node_max_size
  }

  management {
    auto_upgrade                        = false
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

########## NodePool_Firewall ##########
resource "google_compute_firewall" "nodepool_egress_fw_internal" {
  name                                  = "${local.gke_prefix}-nodepool-egress-internal"
  network                               = var.vpc_name
  priority                              = 1000
  direction                             = "EGRESS"
  destination_ranges                    = [ var.private_subnet_cidr, var.public_subnet_cidr ]
  target_tags                           = [ "gke-node" ]

  allow {
    protocol                            = "all"
  }
}

resource "google_compute_firewall" "nodepool_egress_fw_443" {
  name                                  = "${local.gke_prefix}-nodepool-egress-443"
  network                               = var.vpc_name
  priority                              = 1000
  direction                             = "EGRESS"
  destination_ranges                    = [ "0.0.0.0/0" ]
  target_tags                           = [ "gke-node" ]

  allow {
    protocol                            = "tcp"
    ports                               = [ "443" ]
  }
}

resource "google_compute_firewall" "nodepool_egress_fw_53" {
  name                                  = "${local.gke_prefix}-nodepool-egress-53"
  network                               = var.vpc_name
  priority                              = 1000
  direction                             = "EGRESS"
  destination_ranges                    = [ "0.0.0.0/0" ]
  target_tags                           = [ "gke-node" ]

  allow {
    protocol                            = "udp"
    ports                               = [ "53" ]
  }
}

resource "google_compute_firewall" "nodepool_egress_fw_svc_network" {
  name                                  = "${local.gke_prefix}-nodepool-egress-svc-network"
  network                               = var.vpc_name
  priority                              = 1000
  direction                             = "EGRESS"
  destination_ranges                    = [ var.svc_network_cidr_block ]
  target_tags                           = [ "gke-node" ]

  allow {
    protocol                            = "tcp"
    ports                               = [ "5432" ]
  }
}

resource "google_compute_firewall" "nodepool_egress_fw_redis" {
  name                                  = "${local.gke_prefix}-nodepool-egress-redis"
  network                               = var.vpc_name
  priority                              = 1000
  direction                             = "EGRESS"
  destination_ranges                    = [ var.redis_subnet_cidr ]
  target_tags                           = [ "gke-node" ]

  allow {
    protocol                            = "tcp"
    ports                               = [ "6379" ]
  }
}

resource "google_compute_firewall" "nodepool_egress_fw_redis_tls" {
  name                                  = "${local.gke_prefix}-nodepool-egress-redis-tls"
  network                               = var.vpc_name
  priority                              = 1000
  direction                             = "EGRESS"
  destination_ranges                    = [ var.redis_subnet_cidr ]
  target_tags                           = [ "gke-node" ]

  allow {
    protocol                            = "tcp"
    ports                               = [ "6378" ]
  }
}

resource "google_compute_firewall" "nodepool_egress_fw_pods" {
  name                                  = "${local.gke_prefix}-nodepool-egress-pods"
  network                               = var.vpc_name
  priority                              = 1000
  direction                             = "EGRESS"
  destination_ranges                    = [ google_container_cluster.gke_cluster.cluster_ipv4_cidr ]
  target_tags                           = [ "gke-node" ]

  allow {
    protocol                            = "all"
  }
}

resource "google_compute_firewall" "nodepool_egress_fw_all" {
  name                                  = "${local.gke_prefix}-nodepool-egress-all"
  network                               = var.vpc_name
  priority                              = 1100
  direction                             = "EGRESS"
  destination_ranges                    = [ "0.0.0.0/0" ]
  target_tags                           = [ "gke-node" ]

  deny {
    protocol                            = "all"
  }
}

resource "google_compute_firewall" "nodepool_egress_fw_custom" {
  count                                 = length(var.custom_egress_port_list)

  name                                  = "${local.gke_prefix}-nodepool-egress-${var.custom_egress_port_list[count.index]}"
  network                               = var.vpc_name
  priority                              = 1000
  direction                             = "EGRESS"
  destination_ranges                    = [ "0.0.0.0/0" ]
  target_tags                           = [ "gke-node" ]

  allow {
    protocol                            = "tcp"
    ports                               = [ "${var.custom_egress_port_list[count.index]}" ]
  }
}