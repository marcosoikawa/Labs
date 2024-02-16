resource "azurerm_public_ip" "Bastion-PRD-ip" {
  name                = "Bastion-PRD-ip"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "Bastion-PRD" {
  name                = "Bastion-PRD"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_virtual_network.VNET-HUB-PROD.subnet.*.id[2]
    public_ip_address_id = azurerm_public_ip.Bastion-PRD-ip.id
  }
}