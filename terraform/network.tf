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
  for_each            = toset(["privatelink.database.windows.net", "privatelink.azurewebsites.net", "scm.privatelink.azurewebsites.net"])
  name                = each.value
  resource_group_name = azurerm_resource_group.rg-network.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link-zones" {
  for_each              = azurerm_dns_zone.dns-zones
  name                  = "link-${each.value.name}"
  resource_group_name   = azurerm_resource_group.rg-network.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.vnet-01.id
}
