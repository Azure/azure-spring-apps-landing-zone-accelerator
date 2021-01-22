variable "resource_group_name" {}
variable "location" {} 
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

# Hub-Spoke Variables
variable "hub_vnet_name" {}
variable "hub_vnet_addr_prefix" {}

# Hub Subnets

variable "appgw-subnet-name" {}
variable "appgw-subnet-addr" {}
variable "spoke_vnet_name" {}
variable "spoke_vnet_addr_prefix" {}

# Azure Spring Cloud Variables

variable "springboot-service-subnet-name" {}
variable "springboot-service-subnet-addr" {}
variable "springboot-apps-subnet-name" {}
variable "springboot-apps-subnet-addr" {}
variable "springboot-data-subnet-name" {}
variable "springboot-data-subnet-addr" {}
variable "springboot-support-subnet-addr" {}
variable "springboot-support-subnet-name" {}
variable "service_principal_resource_provider_display_name" {
  type    = string
  default = "Azure Spring Cloud Resource Provider"
}

# Azure Firewall Variables
variable "azurefw_name" {}
variable "azurefw_addr_prefix" {}

# Azure Bastion Variables 
variable "azurebastion_name" {}
variable "azurebastion_addr_prefix" {}


# Jump host module
variable "jump_host_name" {}
variable "jump_host_addr_prefix" {}
variable "jump_host_private_ip_addr" {}
variable "jump_host_vm_size" {}
variable "jump_host_admin_username" {}
variable "jump_host_password" {}

# Azure Firewall variables
variable "sc_law_id" {}