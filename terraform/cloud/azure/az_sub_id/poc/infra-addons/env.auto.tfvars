## Terraform Backend Variables
resource_group_name                         = "highflame-poc"
storage_account_name                        = "highflametfstatepoc"
## Enable required services
enable_psql_seeding                         = false
## Resource Variables
common_tags                                 = {
                                                ManagedBy   = "Terraform"
                                              }
az_subscription_id                          = "124af0fd-8168-4247-a7f1-f6c08830f479"
project_name                                = "highflame"
project_env                                 = "poc"
pg_db_list                                  = [ 
                                                "javelin_redteam",
                                                "highflame_guardian"
                                              ]
pg_extensions                               = [
                                                {
                                                  name     = "vector"
                                                  database = "javelin_redteam"
                                                }
                                              ]