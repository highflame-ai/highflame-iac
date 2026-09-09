## Terraform Backend Variables
resource_group_name                         = "highflame-prod"
storage_account_name                        = "highflametfstateprod"
## Resource Variables
common_tags                                 = {
                                                ManagedBy   = "Terraform"
                                              }
az_subscription_id                          = ""
ad_object_id                                = ""
project_name                                = "highflame"
project_env                                 = "prod"
location                                    = "East US"