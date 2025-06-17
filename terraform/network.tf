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
