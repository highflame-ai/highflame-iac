variable "az_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "storage_account_name" {
  description = "Storage Account Name"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "project_env" {
  description = "Project Env"
  type        = string
}

variable "location" {
  description = "Project Location"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "enable_self_keyvault_access" {
  description = "enable self keyvault access"
  type        = bool
}

variable "enable_vnet" {
  description = "enable vnet"
  type        = bool
}

variable "enable_des" {
  description = "enable des"
  type        = bool
}

variable "enable_redis" {
  description = "enable redis"
  type        = bool
}

variable "enable_postgres_deps" {
  description = "enable postgres deps"
  type        = bool
}

variable "enable_postgres_primary" {
  description = "enable postgres primary"
  type        = bool
}

variable "enable_postgres_secondary" {
  description = "enable postgres secondary"
  type        = bool
}

variable "enable_ssl_keyvault" {
  description = "enable ssl keyvault"
  type        = bool
}

variable "enable_application_gw" {
  description = "enable application gateway"
  type        = bool
}

variable "enable_aks" {
  description = "enable aks"
  type        = bool
}

variable "enable_aks_custom_nodepool" {
  description = "enable aks custom nodepool"
  type        = bool
}

variable "enable_svc_iam" {
  description = "enable svc iam for ksa"
  type        = bool
}

variable "enable_traffic_manager" {
  description = "enable traffic manager"
  type        = bool
}

variable "vnet_cidr" {
  description = "vnet cidr"
  type        = string
}

variable "vnet_all_egress_enable" {
  description = "vnet all egress enable"
  type        = bool
}

variable "private_subnet_cidr" {
  description = "private subnet cidr"
  type        = string
}

# variable "private_delegate_subnet_cidr" {
#   description = "private delegate subnet cidr"
#   type        = string
# }

variable "public_subnet_cidr" {
  description = "public subnet cidr"
  type        = string
}

variable "appgw_subnet_cidr" {
  description = "application gw subnet inside the VPC"
  type        = string
}

variable "nat_ip_count" {
  description = "NAT IP Count"
  type        = number
}

variable "redis_sku" {
  description = "redis sku"
  type        = string
}

variable "redis_capacity" {
  description = "redis capacity"
  type        = number
}

variable "postgres_sku_name" {
  description = "Database server sku"
  type        = string
}

variable "postgres_storage_mb" {
  description = "Postgres allocated storage"
  type        = number
}

variable "postgres_storage_tier" {
  description = "Postgres storage tier"
  type        = string
}

variable "postgres_source_server_id" {
  description = "postgres source server id"
  type        = string
}

variable "postgres_server_params" {
  description = "Postgres Server Parameters"
  type = list(object({
    name    = string
    value   = string
  }))
  default = [
    {
      name    = "require_secure_transport"
      value   = "ON"
    },
    {
      name    = "azure.extensions"
      value   = "vector"
    }
  ]
}

variable "workload_identity" {
  description = "workload identity map of namespace and ksa"
  type = list(object({
    id             = number
    namespace      = string
    serviceaccount = string
  }))
  default     = []
}

variable "ad_object_id" {
  description = "ad user or group object id"
  type        = string
  default     = ""
}

variable "enable_delete_lock" {
  description = "enable delete lock"
  type        = bool
}

variable "enable_self_signed_cert" {
  description = "enable self signed certificate - pk12"
  type        = bool
}

variable "ssl_keyvault_secret_ids" {
  description = "List of SSL certificates stored in keyvault"
  type        = list(object({
    name                = string
    keyvault_secret_id  = string
  }))
}

variable "aks_version" {
  description = "aks version"
  type        = string
}

variable "aks_default_node_vm_size" {
  description = "aks default node vm size"
  type        = string
}

variable "aks_service_cidr" {
  description = "aks service cidr"
  type        = string
}

variable "aks_dns_service_ip" {
  description = "aks dns service ip"
  type        = string
}

variable "aks_log_retention_in_days" {
  description = "AKS log retention days"
  type        = number
}

variable "aks_nodes_properties" {
  description = "AKS nodes properties"
  type = list(object({
    name                     = string
    aks_node_vm_size         = string
    aks_node_priority        = string
    aks_node_min_count       = number
    aks_node_max_count       = number
  }))
}

variable "appgw_zones" {
  description = "appgw zones"
  type        = list(string)
}