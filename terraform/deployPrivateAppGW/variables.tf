variable "resource_group_name" {
    type        = string 
    description = "Core Infrastructure Resource Group"
    default     = "sc-corp-rg"
}

variable "location" {
    type    = string
    default = "East US"
} 

variable "appGW_subnet_name" {
    type    = string
    default = "snet-agw"
} 

variable "appGW_vnet_name" {
    type    = string
    default = "vnet-hub"
} 

variable "appGW_ILB_IP" {
    type    = string
    default = "10.0.3.10"
}

variable "az_fw_name" {
    type    = string    
    description = "Name of the Azure Firewall resource"
}

variable "az_fw_pip" {
    type    = string
    default = "azure-firewall-ip"
} 
variable "backendPoolFQDN" {
    type        = string
    description = "FQDN of the backend URL of Azure Spring Cloud Application"
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