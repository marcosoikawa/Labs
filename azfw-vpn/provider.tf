provider "azurerm" {
  features {}
  subscription_id = "b59b030f-edcb-4899-86a8-b4532e8d28b3"
  tenant_id       = "16b3c013-d300-468d-ac64-7eda0820b6d3"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "Hiro-Terraform"
    storage_account_name = "hiroinfratfstate"
    container_name       = "tfstate-azfirewallvpn"
    key                  = "terraform.tfstate"
    subscription_id      = "b59b030f-edcb-4899-86a8-b4532e8d28b3"
    tenant_id            = "16b3c013-d300-468d-ac64-7eda0820b6d3"
  }
}
