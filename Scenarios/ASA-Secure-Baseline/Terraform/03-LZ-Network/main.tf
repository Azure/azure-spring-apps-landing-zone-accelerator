locals  {
  spoke_vnet_name            = "vnet-${var.name_prefix}-${var.location}-SPOKE"
  spoke_rg                   = "rg-${var.name_prefix}-SPOKE"
  #shared_rg                  = "rg-${var.name_prefix}-SHARED"
  private_dns_rg             = "rg-${var.name_prefix}-PRIVATEZONES"

  hub_vnet_name             = ( var.Hub_Vnet_Name == "" ? "vnet-${var.name_prefix}-${var.location}-HUB" : var.Hub_Vnet_Name )     
  hub_rg                    = ( var.Hub_Vnet_RG   == "" ? "rg-${var.name_prefix}-HUB" : var.Hub_Vnet_RG )

  hub_subscriptionId        = ( var.Hub_Vnet_Subscription == "" ? data.azurerm_client_config.current.subscription_id : var.Hub_Vnet_Subscription )
}

data "azurerm_client_config" "current" {}

# Get info about the existing Hub VNET
data "azurerm_virtual_network" "hub_vnet" {

  provider = azurerm.hub-subscription

  name                = local.hub_vnet_name
  resource_group_name = local.hub_rg 
}

# Get info about the existing Hub RG
data "azurerm_resource_group" "hub_rg" {

  provider            = azurerm.hub-subscription
  name                = local.hub_rg 

}


# Spoke Resource group
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

# Private DNS Zones Resource Group
resource "azurerm_resource_group" "private_dns_rg" {
    name                        = local.private_dns_rg 
    location                    = var.location
}



