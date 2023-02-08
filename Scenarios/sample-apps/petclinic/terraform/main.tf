provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

data "azurerm_resource_group" "spoke_rg" {
  name = var.resource_group
}

data "azurerm_spring_cloud_service" "spring_cloud" {
  name                = var.spring_cloud_service
  resource_group_name = var.spring_cloud_resource_group_name
}

data "azurerm_virtual_network" "spoke" {
  name                = var.vnet_spoke_name
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}

# Shared Key Vault
data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg
}
