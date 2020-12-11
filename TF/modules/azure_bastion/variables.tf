variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "azurebastion_name" {
    type        = string
    description = "azurebastion Name"
}

variable "azurebastion_vnet_name" {
    type        = string
    description = "VNet where the Azure Bastion will be deployed to."
}

variable "azurebastion_addr_prefix" {
    type        = string
    description = "Address prefix for Azure Bastion Subnet. Ex. 10.0.0.0/24"
}