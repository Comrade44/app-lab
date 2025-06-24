resource "azurerm_mssql_database" "hyperscale" {
  name = "hyperscale"
  server_id = azurerm_mssql_server.sql-server.id
  sku_name = "HS_S_Gen5_2"
  storage_account_type = "Local"
}