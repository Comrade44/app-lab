resource "azurerm_mssql_elasticpool" "testpool" {
  name                = "test-epool"
  resource_group_name = azurerm_mssql_server.sql-server.resource_group_name
  location            = azurerm_mssql_server.sql-server.location
  server_name         = azurerm_mssql_server.sql-server.name
  sku {
    name     = "GP_Gen5"
    capacity = 2
    tier     = "GeneralPurpose"
    family   = "Gen5"
  }
  per_database_settings {
    min_capacity = 0
    max_capacity = 2
  }
}

resource "azurerm_mssql_database" "db-1" {
  name            = "db-1"
  server_id       = azurerm_mssql_server.sql-server.id
  elastic_pool_id = azurerm_mssql_elasticpool.testpool.id
}

resource "azurerm_mssql_database" "db-2" {
  name            = "db-2"
  server_id       = azurerm_mssql_server.sql-server.id
  elastic_pool_id = azurerm_mssql_elasticpool.testpool.id
}