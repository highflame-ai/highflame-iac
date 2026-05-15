## Terraform Backend Variables
bucket                                 = "javelin-tfstate-poc"
## Enable required services
enable_apis                            = false
enable_binary_authorization            = false
enable_security_policies               = false
enable_ssl_policies                    = false
enable_vpc                             = false
enable_svc_network                     = false
enable_postgres                        = false
enable_redis                           = false
enable_gke                             = false
enable_svc_iam                         = false
enable_gcp_logs                        = false
## Resource Variables
gcp_project                            = "highflame-poc"
region                                 = "us-central1"
default_zone                           = "us-central1-b"
project_name                           = "highflame"
project_env                            = "poc"
gcp_api_list                           = [
                                            "servicenetworking.googleapis.com",
                                            "compute.googleapis.com",
                                            "sqladmin.googleapis.com",
                                            "redis.googleapis.com",
                                            "secretmanager.googleapis.com",
                                            "container.googleapis.com",
                                            "certificatemanager.googleapis.com",
                                            "logging.googleapis.com",
                                            "monitoring.googleapis.com",
                                            "ids.googleapis.com",
                                            "binaryauthorization.googleapis.com",
                                            "dns.googleapis.com",
                                            "containerregistry.googleapis.com",
                                            "cloudkms.googleapis.com",
                                            "containerscanning.googleapis.com",
                                            "cloudresourcemanager.googleapis.com"
                                        ]
private_service_cidr                   = "10.130.0.0/16"
private_subnet_cidr                    = "10.30.0.0/20"
public_subnet_cidr                     = "10.30.16.0/20"
redis_subnet_cidr                      = "10.30.128.0/20"
db_tier                                = "db-custom-2-8192"
redis_memory_size                      = 4
gke_min_master_version                 = "1.33"
gke_nodes_properties                   = [
                                            {
                                                name                           = "general"
                                                node_locations                 = [ "us-central1-b", "us-central1-c" ]
                                                preemptible_node               = false
                                                gke_gpu_enable                 = false
                                                gke_accelerator_type           = "nvidia-tesla-t4"
                                                gke_accelerator_count          = 0
                                                gke_node_capacity_type         = "on-demand" # spot or on-demand
                                                gke_node_machine_type          = "e2-standard-4"
                                                gke_node_min_size              = 3
                                                gke_node_max_size              = 6
                                            }
                                        ]
custom_egress_port_list                = [ "465", "587" ]
gcp_log_retention_days                 = 365
service_namespace                      = "javelin-poc"
workload_identity                      = []
svc_sa_role_list                       = [
                                            "roles/cloudprofiler.agent",
                                            "roles/storage.objectViewer",
                                            "roles/iam.serviceAccountTokenCreator"
                                        ]
create_bucket_list                     = [
                                            {
                                              name          = "highflame-poc-clickhouse-bkp"
                                              region        = "us"
                                              storage_class = "MULTI_REGIONAL"
                                            }
                                          ]