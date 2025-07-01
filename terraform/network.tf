resource "azurerm_resource_group" "rg-network" {
  name     = "rg-network"
  location = "uksouth"
}

resource "azurerm_virtual_network" "vnet-01" {
  name                = "vnet-01"
  location            = azurerm_resource_group.rg-network.location
  resource_group_name = azurerm_resource_group.rg-network.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "vnet-01-snet-app" {
  name                 = "vnet-01-snet-app"
  virtual_network_name = azurerm_virtual_network.vnet-01.name
  resource_group_name  = azurerm_resource_group.rg-network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "dns-zones" {
  for_each            = toset(["privatelink.database.windows.net"])
  name                = each.value
  resource_group_name = azurerm_resource_group.rg-network.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link-zones" {
  for_each              = azurerm_private_dns_zone.dns-zones
  name                  = "link-${each.value.name}"
  resource_group_name   = azurerm_resource_group.rg-network.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.vnet-01.id
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
