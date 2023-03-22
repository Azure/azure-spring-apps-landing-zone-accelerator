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

# Spoke Resource group 
resource "azurerm_resource_group" "spoke_sc_corp_rg" {
    name                        = var.spoke_resource_group_name
    location                    = var.location

}

# Resource group 
resource "azurerm_resource_group" "hub_sc_corp_rg" {
    name                        = var.hub_resource_group_name
    location                    = var.location

}

resource "random_string" "random" {
  length = 5
  upper = false
  special = false

}

locals  {
  spring_cloud_name  = "${var.sc_prefix}-${random_string.random.result}"
  
}



