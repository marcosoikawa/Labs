
resource "azurerm_virtual_network" "VNET01" {
  name                = "VNET01"
  location            = "Brazil South"
  resource_group_name = azurerm_resource_group.AKS-Multicluster.name
  address_space       = ["10.10.0.0/16"]  

  subnet {
    name           = "aks-cni-01"
    address_prefix = "10.10.0.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  subnet {
    name           = "aks-cni-02"
    address_prefix = "10.10.1.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  subnet {
    name           = "aks-kubnet-01"
    address_prefix = "10.10.2.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  subnet {
    name           = "aks-kubnet-02"
    address_prefix = "10.10.3.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  subnet {
    name           = "aks-kubnet-03"
    address_prefix = "10.10.4.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  subnet {
    name           = "aks-kubnet-04"
    address_prefix = "10.10.5.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  subnet {
    name           = "aks-cnio-01"
    address_prefix = "10.10.6.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  subnet {
    name           = "aks-cnio-02"
    address_prefix = "10.10.7.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }

  subnet {
    name           = "agic-01"
    address_prefix = "10.10.10.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  subnet {
    name           = "agic-02"
    address_prefix = "10.10.11.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }

  subnet {
    name           = "appg-cni"
    address_prefix = "10.10.20.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  subnet {
    name           = "appg-kubnet"
    address_prefix = "10.10.21.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }

  subnet {
    name           = "appg-cnio"
    address_prefix = "10.10.22.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  subnet {
    name           = "appg-ngixaas"
    address_prefix = "10.10.23.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }
  
  subnet {
    name           = "apim"
    address_prefix = "10.10.30.0/24"
    security_group = azurerm_network_security_group.NSG-Brz.id
  }

  tags = {
    environment = "infra"
  }
}


#----------------<NSG (Network Security Group Brz)>--------------------------
resource "azurerm_network_security_group" "NSG-Brz" {
  name                = "NSG-Brz"
  location            = "Brazil South"
  resource_group_name = azurerm_resource_group.AKS-Multicluster.name

  tags = {
    environment = "Infra"
  }
}