# Azure provider version 
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "= 3.32.0"
    }

    http = {
      source = "hashicorp/http"
      version = "= 3.2.1"
    }
  }
}

provider "azurerm" {
    features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
     log_analytics_workspace {
      permanently_delete_on_destroy = true
     }
    } 
}

locals  {

  hub_vnet_name            = var.Hub_Vnet_Name
  hub_rg                   = var.Hub_Vnet_RG
  
  shared_rg                = "${var.name_prefix}-SHARED"

  spoke_rg                 = "${var.name_prefix}-SPOKE"
  spoke_vnet_name          = "${var.name_prefix}-vnet-SPOKE"  
  subnet_shared_name       = var.shared-subnet-name
  subnet_cloudsupport_name = var.springboot-support-subnet-name

  jumphost_name            = "${var.name_prefix}-vm"
  
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


# Get info about the existing Shared RG
data "azurerm_resource_group" "shared_rg" {
  name                = local.shared_rg 
}

# get info about current logged in account
data "azurerm_client_config" "current" {}

# get the local egress IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}




