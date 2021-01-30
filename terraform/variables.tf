variable "resource_group_name" {
    type        = string 
    description = "Core Infrastructure Resource Group"
    default     = "sc-corp-rg"
}
variable "location" {
    type = string
    default = "East US"
} 

# mysql module

variable "mysql_server_name_prefix" {
    type = string
    default = "mysql"
}
variable "my_sql_admin" {}
variable "my_sql_password" {
    type = string
    sensitive   = true
}

# Spring Cloud module


variable "app_insights_prefix" {
    type        = string
    default     = "appi"
}

variable "sc_prefix" {
    type        = string 
    description = "Spring Cloud Name"
    default     = "spring"
}

# Key Vault module

variable "keyvault_prefix" {
    type        = string 
    description = "Key Vault Prefix"
    default     = "kv"
}

# LAW module

variable law_prefix {
    type       = string
    default    = "la"
}

# Hub-spoke module 
variable "hub_vnet_name" {
    type        = string 
    description = "Hub VNET name"
    default     = "vnet-hub"
}
variable "hub_vnet_addr_prefix" {
    type        = string 
    description = "Hub VNET prefix"
    default     = "10.0.0.0/16"
}
variable "spoke_vnet_name" {
    type        = string 
    description = "Spoke VNET name"
    default     = "vnet-spoke"
}
variable "spoke_vnet_addr_prefix" {
    type        = string 
    description = "Spoke VNET prefix"
    default     = "10.1.0.0/16"
}
variable "azurefw_name" {
    type        = string
    default     = "fwhub"
}
variable "azurefw_addr_prefix" {
    type        = string 
    description = "Azure Firewall VNET prefix"
    default     = "10.0.1.0/24"
}

# Hub Subnets

variable "appgw-subnet-name" {
    type        = string
    description = "Spring Cloud Service Subnet"
    default     = "snet-agw"
}
variable "appgw-subnet-addr" {
    type        = string
    description = "Spring Cloud CIDR Subnet"
    default     = "10.0.3.0/24"
}

# Azure Spring Cloud Variables

variable "springboot-service-subnet-name" {
    type        = string
    description = "Spring Cloud Service Subnet"
    default     = "snet-runtime"
}
variable "springboot-service-subnet-addr" {
    type        = string
    description = "Spring Cloud CIDR Subnet"
    default     = "10.1.0.0/24"
}
variable "springboot-apps-subnet-name" {
    type        = string
    description = "Spring Cloud Service Subnet"
    default     = "snet-app"
}
variable "springboot-apps-subnet-addr" {
    type        = string
    description = "Spring Cloud CIDR Subnet"
    default     = "10.1.1.0/24"
}

variable "springboot-data-subnet-name" {
    type        = string
    description = "Spring Cloud Data Services Subnet"
    default     = "snet-data"
}
variable "springboot-data-subnet-addr" {
    type        = string
    description = "Spring Cloud Data Services Subnet"
    default     = "10.1.3.0/24"
}

variable "springboot-support-subnet-addr" {
    type        = string
    description = "Spring Cloud Private Link Subnet"
    default     = "10.1.2.0/24"
}

variable "springboot-support-subnet-name" {
    type        = string
    description = "Spring Cloud Private Link Subnet Name"
    default     = "snet-support"
}

# Azure Bastion module

variable "azurebastion_name" {
    type        = string
    default     = "corp-bastion-svc"
}
variable "azurebastion_addr_prefix" {
    type        = string 
    description = "Azure Bastion Address Prefix"
    default     = "10.0.2.0/24"
}

# Jump host module
variable "jump_host_name" {
    type        = string
    default     = "jumphostvm"
}
variable "jump_host_addr_prefix" {
    type        = string 
    description = "Azure Jump Host Address Prefix"
    default     = "10.0.4.0/24"   
}
variable "jump_host_private_ip_addr" {
    type        = string 
    description = "Azure Jump Host Address"
    default     = "10.0.4.5"
}
variable "jump_host_vm_size" {
    type        = string 
    description = "Azure Jump Host VM SKU"
    default     = "Standard_DS3_v2"
}
variable "jump_host_admin_username" {
    type        = string 
    description = "Azure Admin Username"
}
variable "jump_host_password" {
    sensitive   = true
    type        = string 
}

variable "sc_cidr" {
    type        = list
    default     = ["10.3.0.0/16", "10.4.0.0/16", "10.5.0.1/16"]
}
