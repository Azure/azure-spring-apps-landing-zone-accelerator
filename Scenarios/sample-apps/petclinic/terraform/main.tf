# Azure provider version 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.32.0"
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
    key = "lz-petclinic"
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

locals {
  //vnet_spoke_name = "vnet-springlza-${data.azurerm_resource_group.spoke_rg.location}-SPOKE"
  vnet_spoke_name = var.vnet_spoke_name
}

data "azurerm_resource_group" "spoke_rg" {
  name = var.resource_group
}

data "azurerm_resource_group" "private_zones_rg" {
  name = var.private_zones_resource_group_name
}

data "azurerm_resource_group" "spring_apps_rg" {
  name = var.spring_cloud_resource_group_name
}

data "azurerm_spring_cloud_service" "spring_cloud" {
  name                = var.spring_cloud_service
  resource_group_name = var.spring_cloud_resource_group_name
}

data "azurerm_virtual_network" "spoke" {
  name                = local.vnet_spoke_name
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}
