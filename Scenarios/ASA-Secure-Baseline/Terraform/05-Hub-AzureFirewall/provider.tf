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
    key                  = "hub-azurefirewall"
  }

}

provider "azurerm" {
    features {
    } 
}

provider "azurerm" {
    alias = "hub-subscription"
    subscription_id = local.hub_subscriptionId
    features {
    } 
}