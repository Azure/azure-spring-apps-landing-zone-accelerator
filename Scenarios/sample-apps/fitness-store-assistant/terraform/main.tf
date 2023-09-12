# Azure provider version 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.72.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.31.0"
    }
  }

  backend "azurerm" {
    # resource_group_name  = ""   # Partial configuration, provided during "terraform init"
    # storage_account_name = ""   # Partial configuration, provided during "terraform init"
    # container_name       = ""   # Partial configuration, provided during "terraform init"
    key = "lz-acme-fitness-assitant"
  }
}

provider "azurerm" {
  features {}
}

locals {
  vnet_spoke_name       = "vnet-${var.name_prefix}-${data.azurerm_resource_group.spoke_rg.location}-SPOKE"
  spoke_rg_name         = "rg-${var.name_prefix}-${var.spoke_resource_group_suffix}"
  spring_cloud_rg_name  = "rg-${var.name_prefix}-${var.spring_cloud_resource_group_name_suffix}"
  private_zones_rg_name = "rg-${var.name_prefix}-${var.private_zones_resource_group_name_suffix}"
  shared_rg_name        = "rg-${var.name_prefix}-${var.shared_rg_name_suffix}"
}

data "azurerm_resource_group" "spoke_rg" {
  name = local.spoke_rg_name
}

data "azurerm_resource_group" "private_zones_rg" {
  name = local.private_zones_rg_name
}

data "azurerm_resource_group" "springapps_rg" {
  name = local.spring_cloud_rg_name
}

data "azurerm_spring_cloud_service" "sc_enterprise" {
  name                = var.spring_cloud_service
  resource_group_name = local.spring_cloud_rg_name
}

data "azurerm_virtual_network" "spoke_vnet" {
  name                = local.vnet_spoke_name
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}
