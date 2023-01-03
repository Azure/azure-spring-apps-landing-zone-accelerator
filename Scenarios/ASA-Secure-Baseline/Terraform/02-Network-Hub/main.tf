# Azure provider version 
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "= 3.32.0"
    }
  }
}

provider "azurerm" {
    features {} 
}


locals  {

  hub_vnet_name            = "${var.name_prefix}-vnet-HUB"
  hub_rg                   = "${var.name_prefix}-HUB"

  bastion_name             = "${var.name_prefix}-bastion"
 
}




# Resource group 
resource "azurerm_resource_group" "hub_rg" {
    name                        = local.hub_rg
    location                    = var.location

}

# Hub-Spoke VNET 
resource "azurerm_virtual_network" "hub_vnet" {
    name                        = local.hub_vnet_name
    location                    = var.location 
    resource_group_name         = azurerm_resource_group.hub_rg.name
    address_space               = [var.hub_vnet_addr_prefix]

  depends_on = [
    azurerm_resource_group.hub_rg
  ]

}

