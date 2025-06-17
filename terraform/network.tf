resource "azurerm_resource_group" "core-network-rg" {
  name = "rg-uks-lab-net-01"
  location = "uksouth"
}

resource "azurerm_virtual_network" "core-vnet" {
  name = "vnet-uks-lab-core-01"
  location = azurerm_resource_group.core-network-rg.location
  resource_group_name = azurerm_resource_group.core-network-rg.name
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "core-subnet" {
  name = "snet-uks-lab-core-01"
  virtual_network_name = azurerm_virtual_network.core-vnet.name
  resource_group_name = azurerm_resource_group.core-network-rg.name
  address_prefixes = ["10.0.1.0/24"]
}
