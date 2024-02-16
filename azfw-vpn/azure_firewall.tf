#------------------------------<AzFw-PRD>------------------------------------------

resource "azurerm_public_ip" "AzFw-PROD-pip" {
  name                = "AzFw-PROD"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "AzFw-PROD" {
  name                = "AzFw-PROD"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_virtual_network.VNET-HUB-PROD.subnet.*.id[0]
    public_ip_address_id = azurerm_public_ip.AzFw-PROD-pip.id
  }
}


resource "azurerm_firewall_network_rule_collection" "fwRule" {
  name                = "fwRule"
  azure_firewall_name = azurerm_firewall.AzFw-PROD.name
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "all-to-all"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "*",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "Any",      
    ]
  }
}

#------------------------------<AzFw-HML>------------------------------------------

resource "azurerm_public_ip" "AzFw-HML-pip" {
  name                = "AzFw-HML"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#------------------------------<Log Analytics>------------------------------------------


resource "azurerm_log_analytics_workspace" "azfw-la" {
  name                = "azfw-la"
  location            = azurerm_resource_group.AzFw-VPN.location
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "azfw-ds" {
  name               = "azfw-ds"
  target_resource_id = azurerm_firewall.AzFw-PROD.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.azfw-la.id

  enabled_log {
    category = "AzureFirewallNetworkRule"

    retention_policy {
      enabled = false
    }  
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}