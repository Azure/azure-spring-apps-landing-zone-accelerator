# This plan creates a Hub Network with the appropiates Subnets
# It also adds Azure Bastion

resource "random_string" "random" {
  length = 4
  upper = false
  special = false
}

locals  {

  hub_vnet_name            = ( var.Hub_Vnet_Name == "" ? "vnet-${var.name_prefix}-${var.location}-HUB" : var.Hub_Vnet_Name )     
  hub_rg                   = ( var.Hub_Vnet_RG   == "" ? "rg-${var.name_prefix}-HUB" : var.Hub_Vnet_RG )
  bastion_name             = "bastion-${var.name_prefix}-${random_string.random.result}"
 
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
}

