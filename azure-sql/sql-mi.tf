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
  depends_on                   = [azurerm_route_table.sqlmi_rt]
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

resource "azurerm_network_security_group" "sqlmi_nsg" {
  name                = "nsg-sqlmi"
  location            = azurerm_resource_group.rg-network.location
  resource_group_name = azurerm_resource_group.rg-network.name

  security_rule {
    name                       = "Allow-SQL-MI-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["1433", "5022", "11000-11999"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS-Outbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-DNS-Outbound"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "sqlmi_nsg_assoc" {
  subnet_id                 = azurerm_subnet.sql-mi.id
  network_security_group_id = azurerm_network_security_group.sqlmi_nsg.id
}

resource "azurerm_route_table" "sqlmi_rt" {
  name                = "rt-sqlmi"
  location            = azurerm_resource_group.rg-network.location
  resource_group_name = azurerm_resource_group.rg-network.name

  route {
    name           = "Allow-Internet-Outbound"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "sqlmi_rt_assoc" {
  subnet_id      = azurerm_subnet.sql-mi.id
  route_table_id = azurerm_route_table.sqlmi_rt.id
}
