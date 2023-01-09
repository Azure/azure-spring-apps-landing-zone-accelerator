data "terraform_remote_state" "lz-network" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_sa_name
    container_name       = var.container_name
    key                  = "lz-network"
    access_key = var.access_key
  }
}

data "terraform_remote_state" "lz-sharedresources" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_sa_name
    container_name       = var.container_name
    key                  = "lz-sharedresources"
    access_key = var.access_key
  }
}


resource "random_string" "random" {
  length = 4
  upper = false
  special = false
}


locals  {
  spring_apps_name         = "spring-${var.name_prefix}-${var.environment}-${random_string.random.result}"
  springapps_rg            = "rg-${var.name_prefix}-APPS"


  hub_vnet_name            = var.Hub_Vnet_Name
  hub_rg                   = var.Hub_Vnet_RG
  
  spoke_vnet_name            = data.terraform_remote_state.lz-network.outputs.spoke_vnet_name
  spoke_rg                   = data.terraform_remote_state.lz-network.outputs.spoke_rg
  shared_rg                  = data.terraform_remote_state.lz-sharedresources.outputs.shared_rg

  

  subnet_cloudapps_name    = var.springboot-apps-subnet-name
  subnet_cloudsvc_name     = var.springboot-service-subnet-name
  
  
  sc_cidr                  = var.sc_cidr
}

# Get info about the existing Hub VNET
data "azurerm_virtual_network" "hub_vnet" {
  name                = local.hub_vnet_name
  resource_group_name = local.hub_rg
}

# Get info about the existing Hub RG
data "azurerm_resource_group" "hub_rg" {
  name                = var.Hub_Vnet_RG
}

# Get info about the existing Shared RG
data "azurerm_resource_group" "shared_rg" {
  name                = local.shared_rg 
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

data "azurerm_subnet" "azuresbcloudapps" {
  name                 =  local.subnet_cloudapps_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}

data "azurerm_subnet" "azuresbcloudsvc" {
  name                 =  local.subnet_cloudsvc_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name =  local.spoke_rg
}


# Get info about Log Analytics workspace
data "azurerm_log_analytics_workspace" "sc_law" {
  name = data.terraform_remote_state.lz-sharedresources.outputs.law_name
  resource_group_name = data.azurerm_resource_group.shared_rg.name
}

# Create the SpringApps Resource group 
resource "azurerm_resource_group" "springapps_rg" {
    name                        = local.springapps_rg
    location                    = var.location
}
