locals {
  tags                                    = merge(var.common_tags,
                                            {
                                              Project       = var.project_name
                                              Environment   = var.project_env
                                            })
}

module "psql_seeding" {
  count                                   = var.enable_psql_seeding == true ? 1 : 0
  source                                  = "../../../../../../modules/highflame/psql-seeding"
  pg_db_list                              = var.pg_db_list
  pg_extensions                           = var.pg_extensions
}