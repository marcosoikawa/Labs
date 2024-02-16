#----------------Gateway PROD--------------------------
resource "azurerm_public_ip" "VPN-PROD-pip" {
  name                = "VPN-PROD-pip"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "VPNGtw-PROD" {
  name                = "VPNGtw-PROD"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.VPN-PROD-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_virtual_network.VNET-HUB-PROD.subnet.*.id[1]
  }
}



#----------------Gateway PREM PROD--------------------------
resource "azurerm_public_ip" "VPNGtw-P-PRD-pip" {
  name                = "VPNGtw-P-PRD-pip"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "VPNGtw-P-PRD" {
  name                = "VPNGtw-P-PRD"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.VPNGtw-P-PRD-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_virtual_network.PREM-PROD.subnet.*.id[0]
  }
}

#----------------Conection PRD--------------------------
resource "azurerm_virtual_network_gateway_connection" "PPRD-PRD" {
  name                = "PPRD-PRD"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.VPNGtw-P-PRD.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.VPNGtw-PROD.id

  shared_key = "a-v3ry-5ecr37-1p53c-5h4r3d-k3y"
}

resource "azurerm_virtual_network_gateway_connection" "PRD-PPRD" {
  name                = "PRD-PPRD"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.VPNGtw-PROD.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.VPNGtw-P-PRD.id

  shared_key = "a-v3ry-5ecr37-1p53c-5h4r3d-k3y"
}

