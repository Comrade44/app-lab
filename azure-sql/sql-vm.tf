resource "azurerm_resource_group" "rg-sql" {
  name     = "rg-sql"
  location = "uksouth"
}

resource "random_string" "web-app-name" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_network_interface" "sql-vm-nic" {
  name                = "sql-vm-nic"
  location            = azurerm_resource_group.rg-sql.location
  resource_group_name = azurerm_resource_group.rg-sql.name
  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.vnet-01-snet-app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sql-pip.id
  }
}

resource "azurerm_windows_virtual_machine" "sql-vm" {
  name                  = "sql-vm-${random_string.web-app-name.result}"
  location              = azurerm_resource_group.rg-sql.location
  resource_group_name   = azurerm_resource_group.rg-sql.name
  network_interface_ids = [azurerm_network_interface.sql-vm-nic.id]
  size                  = "Standard_B1s"
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "None"
  }
  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2022-ws2022"
    sku       = "sqldev-gen2"
    version   = "latest"
  }
  admin_username = "labadmin"
  admin_password = "LabLogin2025!"
}

resource "azurerm_public_ip" "sql-pip" {
  name                = "sql-pip"
  location            = azurerm_resource_group.rg-sql.location
  resource_group_name = azurerm_resource_group.rg-sql.name
  allocation_method   = "Static"
}