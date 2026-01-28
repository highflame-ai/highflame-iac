########## PostgreSQL_Seeding ##########
resource "postgresql_database" "dbs" {
  for_each                  = toset(var.pg_db_list)

  name                      = each.value
  connection_limit          = -1
}

resource "postgresql_extension" "dbs" {
  depends_on                = [ postgresql_database.dbs ]
  for_each                  = { for ext in var.pg_extensions : ext.name => ext }

  name                      = each.value.name
  database                  = each.value.database
}