variable "resource_group_name" {
    type        = string 
    description = "Core Infrastructure Resource Group"
    default     = "sc-corp-rg"
}
variable "location" {
    type = string
    default = "East US 2"
} 

# my sql module

variable "my_sql_name" {}
variable "my_sql_admin" {}
variable "my_sql_password" {}

# Spring Cloud module

variable "sc_resource_group_name" {
    type        = string 
    description = "Spring Cloud Resource Group"
    default     = "sc-svc-rg"
}


variable "sc_service_name" {
    type        = string 
    description = "Spring Cloud Name"
    default     = "sc"
}

# Key Vault module

variable "keyvault_prefix" {
    type        = string 
    description = "Key Vault Prefix"
    default     = "sckeyvault"
}

# Hub-spoke module 
variable "hub_vnet_name" {
    type        = string 
    description = "Hub VNET name"
    default     = "hub-vnet"
}
variable "hub_vnet_addr_prefix" {
    type        = string 
    description = "Hub VNET prefix"
    default     = "10.230.0.0/16"
}
variable "spoke_vnet_name" {
    type        = string 
    description = "Spoke VNET name"
    default     = "spoke-vnet"
}
variable "spoke_vnet_addr_prefix" {
    type        = string 
    description = "Spoke VNET prefix"
    default     = "10.231.0.0/16"
}
variable "azurefw_name" {
    type        = string
    default     = "corp-azurefw"
}
variable "azurefw_addr_prefix" {
    type        = string 
    description = "Azure Firewall VNET prefix"
    default     = "10.230.0.0/26"
}
# Azure Bastion module

variable "azurebastion_name" {
    type        = string
    default     = "corp-azure-bastion"
}
variable "azurebastion_addr_prefix" {
    type        = string 
    description = "Azure Bastion Address Prefix"
    default     = "10.230.1.0/27"
}

# Jump box module
variable "jump_box_name" {
    type        = string
    default     = "corpjump01"
}
variable "jump_box_addr_prefix" {
    type        = string 
    description = "Azure Jump Host Address Prefix"
    default     = "10.230.4.0/28"   
}
variable "jump_box_private_ip_addr" {
    type        = string 
    description = "Azure Jump Host Address"
    default     = "10.230.4.5"
}
variable "jump_box_vm_size" {
    type        = string 
    description = "Azure Jump Host VM SKU"
    default     = "Standard_DS3_v2"
}
variable "jump_box_admin_username" {
    type        = string 
    description = "Azure Admin Username"
    default     = "azureuser"
}
variable "jump_box_password" {}

