### Notice about changes ######################################################
# We recommend the use of parameters.tfvars for changes.
#   1) Have a particular customization not addressable via parameters.tfvars?
#      Consider filing a feature request at 
#       https://github.com/Azure/azure-spring-apps-landing-zone-accelerator/issues 
# 
#   2) This file should be the same accross all plans 
#  



##################################################
### General deployment variables
##################################################

variable "name_prefix" {
  type        = string
  description = "This prefix will be used when naming resources. 10 characters max."
  validation {
    condition     = length(var.name_prefix) <= 10
    error_message = "name_prefix: 10 characters max allowed."
  }

}

variable "location" {
  type        = string
  description = "Deployment region (ex. East US), for supported regions see https://docs.microsoft.com/en-us/azure/spring-apps/faq?pivots=programming-language-java#in-which-regions-is-azure-spring-apps-basicstandard-tier-available"
}

variable "environment" {
  type        = string
  description = "Deployment environment, example: dev,prod,stg etc."
}

variable "Hub_Vnet_Subscription" {
  type        = string
  description = "The Subscription for the Hub VNET.  Leave empty if the same as Spoke Subscription"
  default     = ""
}

variable "tags" {
  type = map(any)
  default = {
    project = "ASA-Accelerator"
  }
}

variable "SPRINGAPPS_SPN_OBJECT_ID" {
  type    = string
  default = "notused"
}

## This is required for retrieving state
variable "state_sa_name" {}
variable "state_sa_container_name" {}
variable "state_sa_rg" {}

##################################################
### 02-Hub-Network plan variables
##################################################

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

variable "Hub_Vnet_Name" {
  type        = string
  description = "The name of the Hub Vnet"
  default     = ""
}

variable "Hub_Vnet_RG" {
  type        = string
  description = "The name of the Hub RG"
  default     = ""
}

variable "Bastion_Name" {
  type        = string
  description = "This is a globally unique name for bastion"
  default     = ""
}

variable "Bastion_Nsg" {
  type    = string
  default = ""
}

variable "Bastion_Pip" {
  type    = string
  default = ""
}

##################################################
### 03-LZ-Network plan variables
##################################################
variable "Bring_Your_Own_Hub" {
  type        = bool
  description = "Set to true if using your own Hub - the plan will not make modifications related to the Hub"
  default     = false
}

variable "Spoke_Vnet_Name" {
  type        = string
  description = "The name of the Spoke VNET"
  default     = ""
}

variable "Spoke_Rg" {
  type        = string
  description = "The name of the Spoke RG"
  default     = ""
}

variable "Spoke_Private_Dns_Rg" {
  type        = string
  description = "The name of the Private DNS RG"
  default     = ""
}


variable "spoke_vnet_addr_prefix" {
  type        = string
  description = "Spoke VNET prefix"
  default     = "10.1.0.0/16"
}

variable "springboot-service-subnet-name" {
  type        = string
  description = "Spring Apps Service Subnet"
  default     = "snet-runtime"
}

variable "springboot-service-subnet-addr" {
  type        = string
  description = "Spring Apps CIDR Subnet"
  default     = "10.1.0.0/24"
}

variable "springboot-apps-subnet-name" {
  type        = string
  description = "Spring Apps Service Subnet"
  default     = "snet-app"
}

variable "springboot-apps-subnet-addr" {
  type        = string
  description = "Spring Apps Apps CIDR Subnet"
  default     = "10.1.1.0/24"
}

variable "springboot-support-subnet-name" {
  type        = string
  description = "Spring Apps Private Link Subnet Name"
  default     = "snet-support"
}

variable "springboot-support-subnet-addr" {
  type        = string
  description = "Spring Apps Private Link Subnet"
  default     = "10.1.2.0/24"
}

variable "shared-subnet-name" {
  type        = string
  description = "Shared Services Subnet Name"
  default     = "snet-shared"
}

variable "shared-subnet-addr" {
  type        = string
  description = "Shared Services Subnet Address Range"
  default     = "10.1.4.0/24"
}

variable "appgw-subnet-name" {
  type        = string
  description = "App Gateway Subnet Name"
  default     = "snet-agw"
}

variable "appgw-subnet-addr" {
  type        = string
  description = "App Gateway Subnet Address"
  default     = "10.1.5.0/24"
}

variable "springapps_dnszone_name" {
  type        = string
  description = "The SpringApps Private DNS Zone name"
  default     = "private.azuremicroservices.io"
}

variable "keyvault_dnszone_name" {
  type        = string
  description = "The Azure KeyVault Private DNS Zone name"
  default     = "privatelink.vaultcore.azure.net"
}


##################################################
### 04-LZ-SharedResources plan variables
##################################################
variable "Shared_Rg" {
  type        = string
  description = "The name of the Shared RG"
  default     = ""
}


# Jump host module
variable "jump_host_private_ip_addr" {
  type        = string
  description = "Azure Jump Host Address"
  default     = "10.1.4.5"
}
variable "jump_host_vm_size" {
  type        = string
  description = "Azure Jump Host VM SKU"
  default     = "Standard_DS3_v2"
}
variable "jump_host_admin_username" {
  type        = string
  description = "Admin Username, used by Jump Host"
  default     = "lzadmin"
}

# The password for the Jump Host Admin account
variable "jump_host_password" {
  sensitive   = true
  type        = string
  description = "Admin Password, used by Jump Host"
  default     = ""
}


##################################################
### 05-Hub-AzureFirewall plan variables
##################################################

variable "FW_Name" {
  type        = string
  description = "The name for the FW resource"
  default     = ""
}

variable "azurefw_addr_prefix" {
  type        = string
  description = "Azure Firewall VNET prefix"
  default     = "10.0.1.0/24"
}

variable "azure_firewall_zones" {
  type        = set(string)
  description = "Deploy Azure Firewall to these zones"
  default     = []
}

##################################################
### 05-Hub-BYO-Firewall-Routes plan variables
##################################################

# BYO FW IP address
variable "FW_IP" {
  type        = string
  description = "Destination IP for the Default route towards your NVA"
  default     = ""
}

##################################################
### 06-Hub-SpringApps plan variables (both Standard and Enterprise)
##################################################

variable "SpringApps_Name" {
  type        = string
  description = "The name for the Spring Apps resource"
  default     = ""
}

variable "SpringApps_Rg" {
  type        = string
  description = "The name for the Spring apps RG resource"
  default     = ""
}

# The CIDR Range that will be used for the Spring Apps backend cluster
variable "sc_cidr" {
  type        = list(any)
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

variable "spring_apps_zone_redundant" {
  type        = bool
  description = "Should I make Spring Apps Zone Redundant?"
  default     = false
}


##################################################
### 07-LZ-AppGateway plan variables
##################################################

variable "APPGW_Name" {
  type        = string
  description = "The name for the APPGW resource"
  default     = ""
}

variable "APPGW_Rg" {
  type        = string
  description = "The name for the APPGW RG resource"
  default     = ""
}

variable "backendPoolFQDN" {
  type        = string
  description = "FQDN of the backend URL of Azure Spring Cloud Application"
  default     = "default-replace-me.private.azuremicroservices.io"
}

variable "https_password" {
  type        = string
  description = "Password of the PFX certificate file used by the Application Gateway listener"
  sensitive   = true
  default     = ""
}

variable "certfilename" {
  type        = string
  description = "filename of the PFX certificate file within this directory"
  default     = ""
}

variable "azure_app_gateway_zones" {
  type        = set(string)
  description = "Deploy Azure App Gateway to these zones"
  default     = []
}











