# Azure provider version 
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "= 3.32.0"
    }

  }

  backend "azurerm" {
    # resource_group_name  = ""   # Partial configuration, provided during "terraform init"
    # storage_account_name = ""   # Partial configuration, provided during "terraform init"
    # container_name       = ""   # Partial configuration, provided during "terraform init"
    key                  = "lz-network"
  }
}

provider "azurerm" {
    features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
    } 
}

provider "azurerm" {
    alias = "hub-subscription"
    subscription_id = local.hub_subscriptionId
    features {
    } 
}
  
provider "azuread" {
  
}