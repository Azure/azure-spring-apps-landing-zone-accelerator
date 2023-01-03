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
    } 
}

locals  {
  hub_vnet_name            = var.Hub_Vnet_Name
  hub_rg                   = var.Hub_Vnet_RG

  spoke_rg                 = "${var.name_prefix}-SPOKE"
  spoke_vnet_name          = "${var.name_prefix}-vnet-SPOKE"

  shared_rg                = "${var.name_prefix}-SHARED"

  fw_name                  = "${var.name_prefix}-fw"

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

# Get info about the existing Hub VNET
data "azurerm_virtual_network" "hub_vnet" {
  name                = local.hub_vnet_name
  resource_group_name = local.hub_rg
}

# Get info about the existing Hub RG
data "azurerm_resource_group" "hub_rg" {
  name                = var.Hub_Vnet_RG
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

data "azurerm_subnet" "defaulthubsubnet" {
  name                 =  local.subnet_hubdefault_name
  virtual_network_name =  local.hub_vnet_name
  resource_group_name  =  local.hub_rg
}


# Get info about the existing Shared RG
data "azurerm_resource_group" "shared_rg" {
  name                = local.shared_rg 
}




# Get info about Log Analytics workspace
data "azurerm_log_analytics_workspace" "sc_law" {
  name = "${var.name_prefix}-law"
  resource_group_name = data.azurerm_resource_group.shared_rg.name
}

