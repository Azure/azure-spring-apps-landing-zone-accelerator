
data "terraform_remote_state" "lz-network" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_sa_name
    container_name       = var.container_name
    key                  = "lz-network"
    access_key = var.access_key
  }
}


resource "random_string" "random" {
  length = 4
  upper = false
  special = false
}


locals  {
  hub_vnet_name            = ( var.Hub_Vnet_Name == "" ? "vnet-${var.name_prefix}-${var.location}-HUB" : var.Hub_Vnet_Name )     
  hub_rg                   = ( var.Hub_Vnet_RG   == "" ? "rg-${var.name_prefix}-HUB" : var.Hub_Vnet_RG )
  
  shared_rg                = "rg-${var.name_prefix}-SHARED"

  spoke_rg                 = data.terraform_remote_state.lz-network.outputs.spoke_rg
  spoke_vnet_name          = data.terraform_remote_state.lz-network.outputs.spoke_vnet_name
  subnet_shared_name       = var.shared-subnet-name
  subnet_cloudsupport_name = var.springboot-support-subnet-name

  jumphost_name            = "vm${var.name_prefix}${var.environment}"
  
}

# Get info about the existing Hub VNET
data "azurerm_virtual_network" "hub_vnet" {
  name                = local.hub_vnet_name
  resource_group_name = local.hub_rg
}

# Get info about the existing Spoke VNET and subnets
data "azurerm_virtual_network" "spoke_vnet" {
  name                = local.spoke_vnet_name
  resource_group_name = local.spoke_rg
}

data "azurerm_subnet" "snetsharedsubnet" {
  name                 =  local.subnet_shared_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}

data "azurerm_subnet" "azuresbcloudsupport" {
  name                 =  local.subnet_cloudsupport_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}


# Get info about Private DNS Zones
data "azurerm_private_dns_zone" "keyvault_zone" {
  name                 =  var.keyvault_dnszone_name
  resource_group_name  =  local.hub_rg
}


# get info about current logged in account
data "azurerm_client_config" "current" {}

# get the local egress IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}


# Create the Shared Resource group 
resource "azurerm_resource_group" "shared_rg" {
    name                        = local.shared_rg
    location                    = var.location
}



