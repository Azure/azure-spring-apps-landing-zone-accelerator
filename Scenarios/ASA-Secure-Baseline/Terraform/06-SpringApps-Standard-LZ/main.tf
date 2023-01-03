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
    features {
      resource_group {
       prevent_deletion_if_contains_resources = false
     }
    } 
}

locals  {
  spring_apps_name         = "${var.name_prefix}-apps"

  hub_vnet_name            = var.Hub_Vnet_Name
  hub_rg                   = var.Hub_Vnet_RG
  
  shared_rg                = "${var.name_prefix}-SHARED"

  spoke_rg                 = "${var.name_prefix}-SPOKE"
  spoke_vnet_name          = "${var.name_prefix}-vnet-SPOKE"

  springapps_rg            = "${var.name_prefix}-SpringApps"
  

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
  name = "${var.name_prefix}-law"
  resource_group_name = data.azurerm_resource_group.shared_rg.name
}

# Create the SpringApps Resource group 
resource "azurerm_resource_group" "springapps_rg" {
    name                        = local.springapps_rg
    location                    = var.location
}
