##################################################
### Shared Resources variables
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


variable "tags" {
    type        = map 
    default     = { 
        project = "ASA-Accelerator"
    }
}


# Subnets Info
# Spoke Subnets - use the TFVars file if you want to modify these
variable "appgw-subnet-name" {
    type        = string
    description = "App Gateway Subnet Name"
    default     = "snet-agw"
}

# App Gateway
variable "backendPoolFQDN" {
    type        = string
    description = "FQDN of the backend URL of Azure Spring Cloud Application"
    default     = "default-replace-me.private.azuremicroservices.io"
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

variable "azure_app_gateway_zones" {
    type = set(string)
    description = "Deploy Azure App Gateway to these zones"
    default = []
}
