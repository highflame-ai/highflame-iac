module "psql_seeding" {
  count                                         = var.enable_psql_seeding == true ? 1 : 0
  source                                        = "../../../../../modules/highflame/psql-seeding"
  pg_db_list                                    = var.pg_db_list
  pg_extensions                                 = var.pg_extensions
}