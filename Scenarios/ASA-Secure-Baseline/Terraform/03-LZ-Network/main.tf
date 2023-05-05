### Notice about changes ######################################################
# We recommend the use of parameters.tfvars for changes.
# Have a particular customization in mind not addressable via parameters.tfvars?
#  Consider filing a feature request at 
#  https://github.com/Azure/azure-spring-apps-landing-zone-accelerator/issues 
# 

locals  {
  spoke_vnet_name            = ( var.Spoke_Vnet_Name == "" ? "${var.prefix_vnet}${var.name_prefix}-${var.location}-SPOKE${var.suffix_vnet}" : var.Spoke_Vnet_Name)
  spoke_rg                   = ( var.Spoke_Rg == "" ? "${var.prefix_rg}${var.name_prefix}-SPOKE${var.suffix_rg}" : var.Spoke_Rg )
  private_dns_rg             = ( var.Spoke_Private_Dns_Rg == "" ? "${var.prefix_rg}${var.name_prefix}-PRIVATEZONES${var.suffix_rg}" : var.Spoke_Private_Dns_Rg )

  hub_vnet_name              = ( var.Hub_Vnet_Name == "" ? "${var.prefix_vnet}${var.name_prefix}-${var.location}-HUB${var.suffix_vnet}" : var.Hub_Vnet_Name )     
  hub_rg                     = ( var.Hub_Vnet_RG   == "" ? "${var.prefix_rg}${var.name_prefix}-HUB${var.suffix_rg}" : var.Hub_Vnet_RG )
 
  hub_subscriptionId         = ( var.Hub_Vnet_Subscription == "" ? data.azurerm_client_config.current.subscription_id : var.Hub_Vnet_Subscription )

  nsg_svc_name               = "${var.prefix_nsg}${var.springboot-service-subnet-name}${var.suffix_nsg}"
  nsg_apps_name              = "${var.prefix_nsg}${var.springboot-apps-subnet-name}${var.suffix_nsg}"
  nsg_support_name           = "${var.prefix_nsg}${var.springboot-support-subnet-name}${var.suffix_nsg}"
  nsg_shared_name            = "${var.prefix_nsg}${var.shared-subnet-name}${var.suffix_nsg}"
  nsg_appgw_name             = "${var.prefix_nsg}${var.appgw-subnet-name}${var.suffix_nsg}"
  
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

    tags = var.tags
}


# Spoke VNET 
resource "azurerm_virtual_network" "spoke_vnet" {
    name                        = local.spoke_vnet_name
    location                    = var.location 
    resource_group_name         = azurerm_resource_group.spoke_rg.name
    address_space               = [var.spoke_vnet_addr_prefix]

    tags = var.tags    
}

# Private DNS Zones Resource Group
resource "azurerm_resource_group" "private_dns_rg" {
    name                        = local.private_dns_rg 
    location                    = var.location

    tags = var.tags
}



