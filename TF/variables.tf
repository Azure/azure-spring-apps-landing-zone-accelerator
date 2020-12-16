variable "resource_group_name" {}
variable "location" {} 
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

# Spring Cloud module

variable "sc_resource_group_name" {}
variable "sc_service_name" {}

# Key Vault module

variable "keyvault_prefix" {
    type        = string 
    description = "Key Vault Prefix"
    default     = "sckeyvault"
}

# Hub-spoke module 
variable "hub_vnet_name" {}
variable "hub_vnet_addr_prefix" {}
variable "spoke_vnet_name" {}
variable "spoke_vnet_addr_prefix" {}
variable "azurefw_name" {}
variable "azurefw_addr_prefix" {}
variable "azurebastion_name" {}
variable "azurebastion_addr_prefix" {}


# Jump box module
variable "jump_box_name" {}
variable "jump_box_addr_prefix" {}
variable "jump_box_private_ip_addr" {}
//variable "jump_box_ssh_source_addr_prefixes" {}
variable "jump_box_vm_size" {}
variable "jump_box_admin_username" {}
//variable "jump_box_pub_key_name" {}
variable "jump_box_password" {}

