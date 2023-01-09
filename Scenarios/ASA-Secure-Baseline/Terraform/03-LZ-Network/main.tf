locals  {
  spoke_vnet_name            = "vnet-${var.name_prefix}-${var.location}-SPOKE"
  spoke_rg                   = "rg-${var.name_prefix}-SPOKE"
  shared_rg                  = "rg-${var.name_prefix}-SHARED"
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


# Spoke VNET 
resource "azurerm_virtual_network" "spoke_vnet" {
    name                        = local.spoke_vnet_name
    location                    = var.location 
    resource_group_name         = azurerm_resource_group.spoke_rg.name
    address_space               = [var.spoke_vnet_addr_prefix]    
}




