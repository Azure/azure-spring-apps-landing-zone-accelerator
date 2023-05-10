### Notice about changes ######################################################
# We recommend the use of parameters.tfvars for changes.
# Have a particular customization in mind not addressable via parameters.tfvars?
#  Consider filing a feature request at 
#  https://github.com/Azure/azure-spring-apps-landing-zone-accelerator/issues 
# 


data "terraform_remote_state" "lz-network" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_sa_name
    container_name       = var.state_sa_container_name
    key                  = "lz-network"
    resource_group_name  = var.state_sa_rg
  }
}

data "terraform_remote_state" "lz-sharedresources" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_sa_name
    container_name       = var.state_sa_container_name
    key                  = "lz-sharedresources"
    resource_group_name  = var.state_sa_rg
  }
}




locals  {
  # Hub Data can be read from existing state file or local variables
  hub_vnet_name            = ( var.Hub_Vnet_Name == "" ? data.terraform_remote_state.lz-network.outputs.hub_vnet_name : var.Hub_Vnet_Name )     
  hub_rg                   = ( var.Hub_Vnet_RG   == "" ? data.terraform_remote_state.lz-network.outputs.hub_rg : var.Hub_Vnet_RG )
  hub_subscriptionId       = ( var.Hub_Vnet_Subscription == "" ? data.terraform_remote_state.lz-network.outputs.hub_subscriptionId  : var.Hub_Vnet_Subscription )

  spoke_vnet_name            = data.terraform_remote_state.lz-network.outputs.spoke_vnet_name
  spoke_rg                   = data.terraform_remote_state.lz-network.outputs.spoke_rg
  shared_rg                  = data.terraform_remote_state.lz-sharedresources.outputs.shared_rg

  fw_name                  = ( var.FW_Name == "" ? "${var.prefix_fw}${var.name_prefix}${var.suffix_fw}" : var.FW_Name )

  subnet_shared_name       = var.shared-subnet-name
  subnet_cloudapps_name    = var.springboot-apps-subnet-name
  subnet_cloudsvc_name     = var.springboot-service-subnet-name
  subnet_cloudsupport_name = var.springboot-support-subnet-name
  subnet_hubdefault_name   = "default"

  address_range_cloudapps    = data.azurerm_subnet.azuresbcloudapps.address_prefix
  address_range_cloudsvc     = data.azurerm_subnet.azuresbcloudsvc.address_prefix
  address_range_cloudsupport = data.azurerm_subnet.azuresbcloudsupport.address_prefix
  address_range_shared       = data.azurerm_subnet.snetsharedsubnet.address_prefix
  
  
}

# Get info about the current azurerm context
data "azurerm_client_config" "current" {}


# Get info about the existing Hub VNET
data "azurerm_virtual_network" "hub_vnet" {

  provider = azurerm.hub-subscription

  name                = local.hub_vnet_name
  resource_group_name = local.hub_rg
}

# Get info about the existing Hub RG
data "azurerm_resource_group" "hub_rg" {
  provider = azurerm.hub-subscription

  name                = local.hub_rg
}

# Get info about the existing Spoke RG
data "azurerm_resource_group" "spoke_rg" {
  name                = local.spoke_rg
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

data "azurerm_subnet" "azuresbcloudapps" {
  name                 =  local.subnet_cloudapps_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}

data "azurerm_subnet" "azuresbcloudsvc" {
  name                 =  local.subnet_cloudsvc_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}

data "azurerm_subnet" "azuresbcloudsupport" {
  name                 =  local.subnet_cloudsupport_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}

# Get info about the existing Shared RG
data "azurerm_resource_group" "shared_rg" {
  name                = local.shared_rg 
}


# Get info about Log Analytics workspace
data "azurerm_log_analytics_workspace" "sc_law" {
  name = data.terraform_remote_state.lz-sharedresources.outputs.law_name
  resource_group_name = data.azurerm_resource_group.shared_rg.name
}

