variable "resource_group_name" {}
variable "location" {}

variable "azurefw_name" {
    type        = string
    description = "AzureFW Name"
}

variable "azurefw_vnet_name" {
    type        = string
    description = "VNet where the AzureFW will be deployed to."
}

variable "azurefw_addr_prefix" {
    type        = string
    description = "Address prefix for AzureFW Subnet. Ex. 10.0.0.0/24"
}
variable "sc_law_id" {}