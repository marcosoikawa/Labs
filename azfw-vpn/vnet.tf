
resource "azurerm_virtual_network" "VNET-PROD-01" {
  name                = "VNET-PROD-01"
  location            = "Brazil South"
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  address_space       = ["10.0.0.0/24"]  

  subnet {
    name           = "vms"
    address_prefix = "10.0.0.0/25"
    security_group = azurerm_network_security_group.Hiro-NSG-Brz.id
  }
  tags = {
    environment = "infra"
  }
}

resource "azurerm_virtual_network" "VNET-PROD-02" {
  name                = "VNET-PROD-02"
  location            = "Brazil South"
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  address_space       = ["10.0.1.0/24"]  

  subnet {
    name           = "vms"
    address_prefix = "10.0.1.0/25"
    security_group = azurerm_network_security_group.Hiro-NSG-Brz.id
  }
  tags = {
    environment = "infra"
  }
}


#----------------<HUBs>--------------------------

resource "azurerm_virtual_network" "VNET-HUB-PROD" {
  name                = "VNET-HUB-PROD"
  location            = "Brazil South"
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  address_space       = ["10.0.240.0/20"]

  subnet {
    name           = "AzureFirewallSubnet"
    address_prefix = "10.0.240.0/24"
  }
  subnet {
    name           = "GatewaySubnet"
    address_prefix = "10.0.241.0/24"
  }
  subnet {
    name           = "AzureBastionSubnet"
    address_prefix = "10.0.242.0/24"
  }  
  subnet {
    name           = "vms"
    address_prefix = "10.0.243.0/24"
    security_group = azurerm_network_security_group.Hiro-NSG-Brz.id
  }  

}




resource "azurerm_virtual_network" "PREM-PROD" {
  name                = "PREM-PROD"
  location            = "Brazil South"
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  address_space       = ["10.100.0.0/16"]  

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "10.100.0.0/24"
  }
   subnet {
    name           = "vms"
    address_prefix = "10.100.1.0/24"
    security_group = azurerm_network_security_group.Hiro-NSG-Brz.id
  }
  tags = {
    environment = "infra"
  }
}

#----------------<NSG (Network Security Group Brz)>--------------------------
resource "azurerm_network_security_group" "Hiro-NSG-Brz" {
  name                = "Hiro-NSG-Brz"
  location            = "Brazil South"
  resource_group_name = azurerm_resource_group.AzFw-VPN.name

  tags = {
    environment = "Infra"
  }
}