variable "resource_group_name" {
    type        = string 
    description = "Core Infrastructure Resource Group"
    default     = "sc-corp-rg"
}

variable "location" {
    type    = string
    default = "East US"
} 

variable "backendPoolFQDN" {
    type        = string
    description = "FQDN of the backend URL of Azure Spring Cloud Application"
}

variable "appGW_subnet_name" {
    type    = string
    default = "snet-agw"
} 

variable "appGW_vnet_name" {
    type    = string
    default = "vnet-hub"
} 
variable "https_password" {
    type        = string
    description = "Password of the PFX certificate file used by the Application Gateway listener"
    sensitive   = true
}

variable "certfilename" {
    type        = string
    description = "filename of the PFX certificate file within this directory"
}