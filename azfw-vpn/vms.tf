  #https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
  #az vm image list-publishers --location brazilsouth --output table
  
  #1. get pubisher from portal (MicrosoftWindowsServer)
  #2. az vm image list-offers --location brazilsouth --publisher microsoftwindowsserver --output table
  #3. run on desktop cli:
  #   az vm image list --offer WindowsServer --all

#password: https://jakewalsh.co.uk/automating-azure-key-vault-and-secrets-using-terraform/


#------------------------------<VM VM-PROD-01>------------------------------------------

resource "azurerm_network_interface" "VM-PROD-01-nic" {
  name                = "VM-PROD-01-nic"
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  location            = "Brazil South"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_virtual_network.VNET-PROD-01.subnet.*.id[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VM-PROD-01" {
  name                            = "VM-PROD-01"
  resource_group_name             = azurerm_resource_group.AzFw-VPN.name
  location                        = "Brazil South"
  size                            = "Standard_B2ms"
  admin_username                  = "marcos"
  admin_password                  = azurerm_key_vault_secret.vmpassword.value

  network_interface_ids = [
    azurerm_network_interface.VM-PROD-01-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "128"
    name                 = "VM-PROD-01-disk"
  }
    #https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
  #az vm image list-publishers --location brazilsouth --output table  
  #1. get pubisher from portal (MicrosoftWindowsServer)
  #2. az vm image list-offers --location brazilsouth --publisher microsoftwindowsserver --output table
  #3. run on desktop cli:
  #   az vm image list --offer WindowsServer --all
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-smalldisk"
    version   = "latest"
  }  
}



  #------------------------------<VM VM-PROD-02>------------------------------------------

resource "azurerm_network_interface" "VM-PROD-02-nic" {
  name                = "VM-PROD-02-nic"
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  location            = "Brazil South"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_virtual_network.VNET-PROD-02.subnet.*.id[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VM-PROD-02" {
  name                            = "VM-PROD-02"
  resource_group_name             = azurerm_resource_group.AzFw-VPN.name
  location                        = "Brazil South"
  size                            = "Standard_B2ms"
  admin_username                  = "marcos"
  admin_password                  = azurerm_key_vault_secret.vmpassword.value

  network_interface_ids = [
    azurerm_network_interface.VM-PROD-02-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "128"
    name                 = "VM-PROD-02-disk"
  }  
  #https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
  #az vm image list-publishers --location brazilsouth --output table  
  #1. get pubisher from portal (MicrosoftWindowsServer)
  #2. az vm image list-offers --location brazilsouth --publisher microsoftwindowsserver --output table
  #3. run on desktop cli:
  #   az vm image list --offer WindowsServer --all
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-smalldisk"
    version   = "latest"
  }
}

    
#------------------------------<VM VM-PREM-01>------------------------------------------

resource "azurerm_network_interface" "VM-PREM-01-nic" {
  name                = "VM-PREM-01-nic"
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  location            = "Brazil South"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_virtual_network.PREM-PROD.subnet.*.id[1]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VM-PREM-01" {
  name                            = "VM-PREM-01"
  resource_group_name             = azurerm_resource_group.AzFw-VPN.name
  location                        = "Brazil South"
  size                            = "Standard_B2ms"
  admin_username                  = "marcos"
  admin_password                  = azurerm_key_vault_secret.vmpassword.value

  network_interface_ids = [
    azurerm_network_interface.VM-PREM-01-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "128"
    name                 = "VM-PREM-01-disk"
  }
  
  #https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
  #az vm image list-publishers --location brazilsouth --output table  
  #1. get pubisher from portal (MicrosoftWindowsServer)
  #2. az vm image list-offers --location brazilsouth --publisher microsoftwindowsserver --output table
  #3. run on desktop cli:
  #   az vm image list --offer WindowsServer --all
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-smalldisk"
    version   = "latest"
  }
}



  #------------------------------<VM VM-SEC-PRD>------------------------------------------

resource "azurerm_network_interface" "VM-SEC-PRD-nic" {
  name                = "VM-SEC-PRD-nic"
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  location            = "Brazil South"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_virtual_network.VNET-HUB-PROD.subnet.*.id[3]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VM-SEC-PRD" {
  name                            = "VM-SEC-PRD"
  resource_group_name             = azurerm_resource_group.AzFw-VPN.name
  location                        = "Brazil South"
  size                            = "Standard_B2ms"
  admin_username                  = "marcos"
  admin_password                  = azurerm_key_vault_secret.vmpassword.value

  network_interface_ids = [
    azurerm_network_interface.VM-SEC-PRD-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "128"
    name                 = "VM-SEC-PRD-disk"
  }
  #https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
  #az vm image list-publishers --location brazilsouth --output table  
  #1. get pubisher from portal (MicrosoftWindowsServer)
  #2. az vm image list-offers --location brazilsouth --publisher microsoftwindowsserver --output table
  #3. run on desktop cli:
  #   az vm image list --offer WindowsServer --all
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-smalldisk"
    version   = "latest"
  }  
}


  #------------------------------<VM VM-HUB-PRD>------------------------------------------

resource "azurerm_network_interface" "VM-HUB-PRD-nic" {
  name                = "VM-HUB-PRD-nic"
  resource_group_name = azurerm_resource_group.AzFw-VPN.name
  location            = "Brazil South"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_virtual_network.VNET-HUB-PROD.subnet.*.id[3]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VM-HUB-PRD" {
  name                            = "VM-HUB-PRD"
  resource_group_name             = azurerm_resource_group.AzFw-VPN.name
  location                        = "Brazil South"
  size                            = "Standard_B2ms"
  admin_username                  = "marcos"
  admin_password                  = azurerm_key_vault_secret.vmpassword.value

  network_interface_ids = [
    azurerm_network_interface.VM-HUB-PRD-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "128"
    name                 = "VM-HUB-PRD-disk"
  }
  #https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
  #az vm image list-publishers --location brazilsouth --output table  
  #1. get pubisher from portal (MicrosoftWindowsServer)
  #2. az vm image list-offers --location brazilsouth --publisher microsoftwindowsserver --output table
  #3. run on desktop cli:
  #   az vm image list --offer WindowsServer --all
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-smalldisk"
    version   = "latest"
  }  
}