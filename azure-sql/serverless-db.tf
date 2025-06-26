resource "azurerm_mssql_database" "serverless" {
  name = "serverless"
  server_id = azurerm_mssql_server.sql-server.id
  auto_pause_delay_in_minutes = 15
  sku_name = "GP_S_Gen5_1"
  min_capacity = 0.5
}