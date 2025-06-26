resource "azurerm_resource_group" "rg-sql" {
  name     = "rg-sql"
  location = "uksouth"
}

resource "random_string" "web-app-name" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_mssql_managed_instance" "sql-mi" {
  name                         = "sql-mi"
  license_type                 = "LicenseIncluded"
  location                     = azurerm_resource_group.rg-sql.location
  resource_group_name          = azurerm_resource_group.rg-sql.name
  sku_name                     = "GP_Gen5"
  storage_size_in_gb           = 32
  subnet_id                    = azurerm_subnet.vnet-01-snet-app.id
  vcores                       = 4
  administrator_login          = "labadmin"
  administrator_login_password = "LabLogin2025!"
}

resource "azurerm_mssql_firewall_rule" "allow-ms-trusted-services" {
  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_mssql_managed_instance.sql-mi.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}