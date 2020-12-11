variable "resource_group_name" {}
variable "location" {} 
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

# Hub-Spoke Variables
variable "hub_vnet_name" {
    type        = string 
    description = "VNet name for hub-vnet"
    default     = "hub-vnet"
}

variable "hub_vnet_addr_prefix" { 
    type        = string
    description = "VNet address prefix"
    default     = "10.0.0.0/16"
}

variable "spoke_vnet_name" {
    type        = string 
    description = "VNet name for spoke-vnet"
    default     = "spoke-vnet"
}

variable "spoke_vnet_addr_prefix" { 
    type        = string
    description = "VNet address prefix"
    default     = "10.1.0.0/16"
}

# Azure Spring Cloud Variables

variable "springboot-service-subnet-name" {
    type        = string
    description = "Spring Cloud Service Subnet"
    default     = "sc-service-subnet"
}
variable "springboot-service-subnet-addr" {
    type        = string
    description = "Spring Cloud CIDR Subnet"
    default     = "10.231.1.0/24"
}
variable "springboot-apps-subnet-name" {
    type        = string
    description = "Spring Cloud Service Subnet"
    default     = "sc-apps-subnet"
}
variable "springboot-apps-subnet-addr" {
    type        = string
    description = "Spring Cloud CIDR Subnet"
    default     = "10.231.2.0/24"
}
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


# Jump box module
variable "jump_box_name" {}
variable "jump_box_addr_prefix" {}
variable "jump_box_private_ip_addr" {}
variable "jump_box_ssh_source_addr_prefixes" {}
variable "jump_box_vm_size" {}
variable "jump_box_admin_username" {}
variable "jump_box_pub_key_name" {}