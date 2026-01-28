## Terraform Backend Variables
resource_group_name             = "highflame-poc"
storage_account_name            = "highflametfstatepoc"
## Enable required services
enable_storageclass             = false
enable_namespace                = false
enable_cert_manager             = false
enable_docker_secret            = false
enable_aks_addons_secret        = false
## Resource Variables
common_tags                     = {
                                    ManagedBy   = "Terraform"
                                  }
az_subscription_id              = ""
project_name                    = "highflame"
project_env                     = "poc"
location                        = "East US"
service_namespace               = "highflame-poc"
cert_acme_email                 = ""
### WARNING : Don't save this
registry_password               = ""