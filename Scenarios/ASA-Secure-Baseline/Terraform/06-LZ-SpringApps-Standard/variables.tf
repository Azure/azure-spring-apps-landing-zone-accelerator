##################################################
### Shared Resources variables
##################################################

variable "name_prefix" {
    type= string
    description = "This prefix will be used when naming resources"

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


# Info about Precreated Hub and Spoke VNETS

variable "Hub_Vnet_Name" {
    type = string    
    description = "The name of the Hub Vnet"
    default     = ""
} 

variable "Hub_Vnet_RG" {
    type = string    
    description = "The name of the Hub RG"
    default     = ""
}



# Subnets Info

# Spoke Subnets - use the TFVars file if you want to modify these
variable "springboot-service-subnet-name" {
    type        = string
    description = "Spring Apps Service Subnet"
    default     = "snet-runtime"
}

variable "springboot-apps-subnet-name" {
    type        = string
    description = "Spring Apps Service Subnet"
    default     = "snet-app"
}

variable "springboot-data-subnet-name" {
    type        = string
    description = "Spring Apps Data Services Subnet"
    default     = "snet-data"
}



variable "springapps_dnszone_name" {
    type = string
    description = "The SpringApps Private DNS Zone name"
    default = "private.azuremicroservices.io"
}


# Azure Spring Apps Specific

# The CIDR Range that will be used for the Spring Apps backend cluster
variable "sc_cidr" {
    type        = list
    description = "Spring Apps backend ranges - Spring apps internal"
    default     = ["10.3.0.0/16", "10.4.0.0/16", "10.5.0.1/16"]
}

variable "internal_lb_svc_load_balancer_name" {
    type    = string
    default = "kubernetes-internal"
}
variable "private_dns_a_record_a_record_name" {
  type    = string
  default = "*"
}

variable "private_dns_a_record_a_record_ttl" {
  type    = number
  default = 3600
}


## This is required for retrieving state
variable "state_sa_name" {}

variable "container_name" {}

# Storage Account Access Key
variable "access_key" {}
