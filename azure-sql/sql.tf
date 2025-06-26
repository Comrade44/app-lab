resource "azurerm_resource_group" "rg-sql" {
  name     = "rg-sql"
  location = "uksouth"
}

resource "random_string" "web-app-name" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_mssql_server" "sql-server" {
  name                         = "sql-server-${random_string.web-app-name.result}"
  location                     = azurerm_resource_group.rg-sql.location
  resource_group_name          = azurerm_resource_group.rg-sql.name
  version                      = "12.0"
  administrator_login          = "labadmin"
  administrator_login_password = "LabLogin2025!"
}

resource "azurerm_mssql_firewall_rule" "allow-ms-trusted-services" {
  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_mssql_server.sql-server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}