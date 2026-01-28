## Enable required services
enable_vpc                               = false
enable_redis                             = false
enable_eks                               = false
enable_eks_managed_nodes                 = false
enable_alb_sg                            = false
enable_svc_iam                           = false
enable_svc_kms                           = false
enable_global_accelerator                = false
enable_global_accelerator_endpoint       = false
enable_aurora_postgres_deps              = false
enable_aurora_postgres_primary           = false
enable_aurora_postgres_secondary         = false
## Resource Variables
common_tags                              = {
                                               ManagedBy   = "Terraform"
                                            }
region                                   = "us-east-1"
project_name                             = "highflame"
project_env                              = "poc"
vpc_cidr                                 = "10.1.0.0/16" # Mask must be /16
azs                                      = [
                                                "us-east-1a",
                                                "us-east-1b",
                                                "us-east-1c"
                                            ]
public_subnets                           = [
                                                "10.1.0.0/20",
                                                "10.1.16.0/20",
                                                "10.1.32.0/20"
                                            ]
private_subnets                          = [
                                                "10.1.48.0/20",
                                                "10.1.64.0/20",
                                                "10.1.80.0/20"
                                            ]
database_subnets                         = [
                                                "10.1.96.0/20",
                                                "10.1.112.0/20",
                                                "10.1.128.0/20"
                                            ]
redis_node_type                          = "cache.m5.large"
aurora_instance_db_class                 = "db.r6g.large"
aurora_master_cluster_region             = "us-east-1"
aurora_global_cluster_identifier         = ""
eks_cloudwatch_retention                 = 30
redis_cloudwatch_retention               = 30
eks_cluster_version                      = "1.33"
eks_managed_nodes_properties             = [
                                                {
                                                    name                           = "general"
                                                    eks_node_ami_type              = "AL2023_x86_64_STANDARD"
                                                    eks_node_ami_id                = ""
                                                    eks_node_instance_type         = "t3.xlarge"
                                                    eks_node_capacity_type         = "ON_DEMAND" # ON_DEMAND or SPOT
                                                    eks_node_block_device_name     = "/dev/xvda"
                                                    eks_node_block_device_size     = 100
                                                    eks_node_min_size              = 1
                                                    eks_node_max_size              = 1
                                                    enable_bootstrap_user_data     = false # true only if you are using eks_node_ami_id
                                                },
                                                {
                                                    name                           = "gpu"
                                                    eks_node_ami_type              = "AL2023_x86_64_NVIDIA"
                                                    eks_node_ami_id                = ""
                                                    eks_node_instance_type         = "g4dn.xlarge"
                                                    eks_node_capacity_type         = "ON_DEMAND" # ON_DEMAND or SPOT
                                                    eks_node_block_device_name     = "/dev/xvda"
                                                    eks_node_block_device_size     = 100
                                                    eks_node_min_size              = 2
                                                    eks_node_max_size              = 2
                                                    enable_bootstrap_user_data     = false # true only if you are using eks_node_ami_id
                                                }
                                            ]
global_accelerator_listener_arn          = ""
global_accelerator_traffic_percentage    = 100
alb_arn                                  = ""