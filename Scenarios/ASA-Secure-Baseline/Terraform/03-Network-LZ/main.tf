# Azure provider version 
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "= 3.32.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.31.0"
    }
  }
}

provider "azurerm" {
    features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
    } 
}



locals  {

  spoke_vnet_name            = "${var.name_prefix}-vnet-SPOKE"
  spoke_rg                   = "${var.name_prefix}-SPOKE"
  shared_rg                  = "${var.name_prefix}-SHARED"
 
}




# Get info about the existing Hub VNET
data "azurerm_virtual_network" "hub_vnet" {
  name                = var.Hub_Vnet_Name
  resource_group_name = var.Hub_Vnet_RG
}

# Get info about the existing Hub RG
data "azurerm_resource_group" "hub_rg" {
  name                = var.Hub_Vnet_RG
}


# Resource group 
resource "azurerm_resource_group" "spoke_rg" {
    name                        = local.spoke_rg
    location                    = var.location
}

# Create the Shared Resource group 
resource "azurerm_resource_group" "shared_rg" {
    name                        = local.shared_rg
    location                    = var.location
}

# Spoke VNET 
resource "azurerm_virtual_network" "spoke_vnet" {
    name                        = local.spoke_vnet_name
    location                    = var.location 
    resource_group_name         = azurerm_resource_group.spoke_rg.name
    address_space               = [var.spoke_vnet_addr_prefix]    
}




