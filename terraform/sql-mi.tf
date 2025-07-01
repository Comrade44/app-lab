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
  name                         = "sql-mi-${random_string.web-app-name.result}"
  license_type                 = "LicenseIncluded"
  location                     = azurerm_resource_group.rg-sql.location
  resource_group_name          = azurerm_resource_group.rg-sql.name
  sku_name                     = "GP_Gen5"
  storage_size_in_gb           = 32
  subnet_id                    = azurerm_subnet.sql-mi.id
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

resource "azurerm_subnet" "sql-mi" {
  name                 = "sql-mi"
  resource_group_name  = azurerm_resource_group.rg-network.name
  virtual_network_name = azurerm_virtual_network.vnet-01.name
  address_prefixes     = ["10.0.2.0/24"]


  delegation {
    name = "sql-mi"
    service_delegation {
      name = "Microsoft.Sql/managedInstances"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}