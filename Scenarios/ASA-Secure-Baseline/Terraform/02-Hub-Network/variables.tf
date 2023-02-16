##################################################
### Network Hub Variables
##################################################

variable "name_prefix" {
    type= string
    description = "This prefix will be used when naming resources. 10 characters max."
    validation {
      condition = length(var.name_prefix)<=10
      error_message = "name_prefix: 10 characters max allowed."
    }

}

variable "location" {
    type = string    
    description = "Deployment region (ex. East US), for supported regions see https://docs.microsoft.com/en-us/azure/spring-apps/faq?pivots=programming-language-java#in-which-regions-is-azure-spring-apps-basicstandard-tier-available"
}

variable "environment" {
    type = string    
    description = "Deployment environment, example: dev,prod,stg etc."
}

variable "Hub_Vnet_Subscription" {
    type = string    
    description = "The Subscription for the Hub VNET.  Leave empty if the same as Spoke Subscription"
    default =""
}

variable "tags" {
    type        = map 
    default     = { 
        project = "ASA-Accelerator"
    }
}

# HUB VNET
variable "hub_vnet_addr_prefix" {
    type        = string 
    description = "Hub VNET prefix"
    default     = "10.0.0.0/16"
}

variable "azurebastion_addr_prefix" {
    type        = string 
    description = "Azure Bastion Address Prefix"
    default     = "10.0.0.0/24"
}


# The following variables are not used in this particular plan
# These are present to prevent warnings when using the provided
# sample parameter file.

variable "Hub_Vnet_Name" {
    type = string    
    description = "The name of the Hub Vnet"
    default =""
} 

variable "Hub_Vnet_RG" {
    type = string    
    description = "The name of the Hub RG"
    default =""
}


## This is required for retrieving state
variable "state_sa_name" {}

variable "container_name" {}

# Storage Account Access Key
variable "access_key" {}
