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
    key = "lz-acme-fitness-assistant"
  }
}

provider "azurerm" {
  features {
  }
}

locals {
  vnet_spoke_name = "vnet-${var.name_prefix}-${data.azurerm_resource_group.spoke_rg.location}-SPOKE"
}

data "azurerm_resource_group" "spoke_rg" {
  name = var.spoke_resource_group_name
}

data "azurerm_resource_group" "private_zones_rg" {
  name = var.private_zones_resource_group_name
}

data "azurerm_resource_group" "springapps_rg" {
  name = var.spring_cloud_resource_group_name
}

data "azurerm_spring_cloud_service" "sc_enterprise" {
  name                = var.spring_cloud_service
  resource_group_name = var.spring_cloud_resource_group_name
}

data "azurerm_virtual_network" "spoke_vnet" {
  name                = local.vnet_spoke_name
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}
