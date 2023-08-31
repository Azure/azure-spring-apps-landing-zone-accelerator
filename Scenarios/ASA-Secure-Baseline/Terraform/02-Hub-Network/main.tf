# This plan creates a Hub Network with the appropiates Subnets
# It also adds Azure Bastion

### Notice about changes ######################################################
# We recommend the use of parameters.tfvars for changes.
# Have a particular customization in mind not addressable via parameters.tfvars?
#  Consider filing a feature request at 
#  https://github.com/Azure/azure-spring-apps-landing-zone-accelerator/issues 
# 

resource "random_string" "random" {
  length = 4
  upper = false
  special = false
}

data "azurerm_client_config" "current" {}

locals  {

  hub_vnet_name            =  ( var.Hub_Vnet_Name == "" ? "${var.prefix_vnet}${var.name_prefix}-${var.location}-HUB${var.suffix_vnet}" : var.Hub_Vnet_Name )     
  hub_rg                   =  ( var.Hub_Vnet_RG   == "" ? "${var.prefix_rg}${var.name_prefix}-HUB${var.suffix_rg}" : var.Hub_Vnet_RG )
  bastion_name             =  ( var.Bastion_Name  == "" ? "${var.prefix_bastion}${var.name_prefix}-${random_string.random.result}${var.suffix_bastion}" : var.Bastion_Name )
  hub_subscriptionId       =  ( var.Hub_Vnet_Subscription == "" ? data.azurerm_client_config.current.subscription_id : var.Hub_Vnet_Subscription )

  bastion_nsg              =  ( var.Bastion_Nsg   == "" ? "${var.prefix_nsg}bastion${var.name_prefix}-${random_string.random.result}${var.suffix_nsg}" : var.Bastion_Nsg )
  bastion_pip              =  ( var.Bastion_Pip   == "" ? "${var.prefix_pip}bastion${var.name_prefix}-${random_string.random.result}${var.suffix_pip}" : var.Bastion_Pip )
}



# Resource group 
resource "azurerm_resource_group" "hub_rg" {

    provider = azurerm.hub-subscription

    name                        = local.hub_rg
    location                    = var.location

    tags = var.tags
}

# Hub-Spoke VNET 
resource "azurerm_virtual_network" "hub_vnet" {

    provider = azurerm.hub-subscription

    name                        = local.hub_vnet_name
    location                    = var.location 
    resource_group_name         = azurerm_resource_group.hub_rg.name
    address_space               = [var.hub_vnet_addr_prefix]

    tags = var.tags
}

