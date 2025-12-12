## Terraform Backend Variables
resource_group_name             = "javelin-poc"
storage_account_name            = "javelintfstatepoc"
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
project_name                    = "javelin"
project_env                     = "poc"
location                        = "East US"
service_namespace               = "javelin-poc"
cert_acme_email                 = ""
### WARNING : Don't save this
registry_password               = ""