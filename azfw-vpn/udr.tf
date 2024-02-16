#------------------------------<UDR-PRD-01>------------------------------------------
resource "azurerm_route_table" "UDR-PRD-01" {
  name                          = "UDR-PRD-01"
  location                      = azurerm_resource_group.AzFw-VPN.location
  resource_group_name           = azurerm_resource_group.AzFw-VPN.name
  disable_bgp_route_propagation = true

  route {
    name           = "PRD-02"
    address_prefix = "10.0.0.0/16"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address  = azurerm_firewall.AzFw-PROD.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_route_table_association" "UDR-PRD-01" {
  subnet_id      = azurerm_virtual_network.VNET-PROD-01.subnet.*.id[0]
  route_table_id = azurerm_route_table.UDR-PRD-01.id
}


#------------------------------<UDR-PRD-02>------------------------------------------
resource "azurerm_route_table" "UDR-PRD-02" {
  name                          = "UDR-PRD-02"
  location                      = azurerm_resource_group.AzFw-VPN.location
  resource_group_name           = azurerm_resource_group.AzFw-VPN.name
  disable_bgp_route_propagation = true

  route {
    name           = "PRD-01"
    address_prefix = "10.0.0.0/16"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address  = azurerm_firewall.AzFw-PROD.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "Production"
  }
}
resource "azurerm_subnet_route_table_association" "UDR-PRD-02" {
  subnet_id      = azurerm_virtual_network.VNET-PROD-02.subnet.*.id[0]
  route_table_id = azurerm_route_table.UDR-PRD-02.id
}



#------------------------------<UDR-PROD-Gtw>------------------------------------------
resource "azurerm_route_table" "UDR-PROD-Gtw" {
  name                          = "UDR-PROD-Gtw"
  location                      = azurerm_resource_group.AzFw-VPN.location
  resource_group_name           = azurerm_resource_group.AzFw-VPN.name
  disable_bgp_route_propagation = false

  route {
    name           = "PRD-01"
    address_prefix = "10.0.0.0/24"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address  = azurerm_firewall.AzFw-PROD.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "Production"
  }
}
resource "azurerm_subnet_route_table_association" "UDR-PROD-Gtw0" {
  subnet_id      = azurerm_virtual_network.VNET-HUB-PROD.subnet.*.id[3]
  route_table_id = azurerm_route_table.UDR-PROD-Gtw.id
}



#------------------------------<UDR-PREM>------------------------------------------
resource "azurerm_route_table" "UDR-PREM" {
  name                          = "UDR-PREM"
  location                      = azurerm_resource_group.AzFw-VPN.location
  resource_group_name           = azurerm_resource_group.AzFw-VPN.name
  disable_bgp_route_propagation = false
}
resource "azurerm_subnet_route_table_association" "UDR-PREM" {
  subnet_id      = azurerm_virtual_network.PREM-PROD.subnet.*.id[0]
  route_table_id = azurerm_route_table.UDR-PREM.id
}

#------------------------------<UDR-PROD-Fw>------------------------------------------
resource "azurerm_route_table" "UDR-PROD-Fw" {
  name                          = "UDR-PROD-Fw"
  location                      = azurerm_resource_group.AzFw-VPN.location
  resource_group_name           = azurerm_resource_group.AzFw-VPN.name
  disable_bgp_route_propagation = false

  route {
  name           = "Internet"
  address_prefix = "0.0.0.0/0"
  next_hop_type = "Internet"  
  }

}
resource "azurerm_subnet_route_table_association" "UDR-PROD-Fw0" {
  subnet_id      = azurerm_virtual_network.VNET-HUB-PROD.subnet.*.id[0]
  route_table_id = azurerm_route_table.UDR-PROD-Fw.id
}
