##################################################
### General defaults
##################################################

variable "spoke_resource_group_name" {
    type        = string 
    description = "Spoke Core Infrastructure Resource Group"
    default     = "sc-corp-spoke-rg"
}

variable "hub_resource_group_name" {
    type        = string 
    description = "Hub Core Infrastructure Resource Group"
    default     = "sc-corp-hub-rg"
}

variable "location" {
    type = string
    default = "East US"
} 

variable "skuTier" {
    type        = string 
    description = "Deploy the Enterprise Tier [Standard or Enterprise]?"

    validation {
        condition     =  var.skuTier == "Standard" || var.skuTier == "standard" || var.skuTier == "Enterprise" || var.skuTier == "enterprise"
        error_message = "Please type either Standard or Enterprise for the Tier."
    }    
}

variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

##################################################
### Additional customizations
##################################################


#############################
### Networking
#############################

# HUB VNET
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
##LF## fix descriptions on this
variable "shared-subnet-name" {
    type        = string
    description = "Spring Cloud Service Subnet"
    default     = "snet-shared"
}
variable "shared-subnet-addr" {
    type        = string
    description = "Spring Cloud CIDR Subnet"
    default     = "10.0.4.0/24"
}

# Spoke VNET
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

# Spoke Subnets
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

# Azure Firewall (Hub)

variable "azurefw_name" {
    type        = string
    default     = "fwhub"
}
variable "azurefw_addr_prefix" {
    type        = string 
    description = "Azure Firewall VNET prefix"
    default     = "10.0.1.0/24"
}

#############################
### Spring Apps
#############################


# Spring Apps defaults
variable "app_insights_prefix" {
    type        = string
    default     = "appi"
}

variable "sc_prefix" {
    type        = string 
    description = "Spring Cloud Name"
    default     = "spring"
}

variable "sc_cidr" {
    type        = list
    description = "Spring Cloud backend ranges - Spring apps internal"
    default     = ["10.3.0.0/16", "10.4.0.0/16", "10.5.0.1/16"]
}


#############################
### Supporting components
#############################

# Azure Spring Apps Enterprise only variables
variable "redis_cache_name_prefix" {
    type        = string
    description = "Redis Cache resource name prefix"
    default     = "redis"
}

variable "postgres_name_prefix" {
    type        = string
    description = "Postgres resource name prefix"
    default     = "postgres"
}

# MySQL
variable "mysql_server_name_prefix" {
    type = string
    default = "mysql"
}


# Key Vault module
variable "keyvault_prefix" {
    type        = string 
    description = "Key Vault Prefix"
    default     = "keyvault"
}

# LAW module
variable law_prefix {
    type       = string
    default    = "la"
}


#############################
### Management infrastructure
#############################

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





