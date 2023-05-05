
###### Naming standard customizations variables ###### DO NOT MODIFY ##
# Warning: Change these prefixes using the parameters.tfvars file
#          To avoid issues accross different plan modules
#######################################################################

####### Prefixes ########

variable "prefix_rg" {
    type = string
    default = "rg-"    
}
variable "prefix_vnet" {
    type = string
    default = "vnet-"    
}

variable "prefix_bastion" {
    type = string
    default = "bastion-"      
}

variable "prefix_nsg" {
    type = string
    default = "nsg-"    
}

variable "prefix_pip" {
    type = string
    default = "pip-"    
}

variable "prefix_nic" {
    type = string
    default = "nic-"    
}

variable "prefix_keyvault" {
    type = string
    default = "kv-"    
}

variable "prefix_law" {
    type = string
    default = "law-"    
}

variable "prefix_app_insights" {
    type = string
    default = "ai-"    
}

variable "prefix_fw" {
    type = string
    default = "fw-"    
}

variable "prefix_spring" {
    type = string
    default = "spring-"    
}

variable "prefix_appgw" {
    type = string
    default = "appgw-"    
}

variable "prefix_vm" {
    type = string
    default = "vm"    
}

variable "prefix_disk" {
    type = string
    default = "disk-"    
}



####### Suffixes #############
variable "suffix_rg" {
    type = string
    default = ""    
}
variable "suffix_vnet" {
    type = string
    default = ""    
}

variable "suffix_bastion" {
    type = string
    default = ""      
}

variable "suffix_nsg" {
    type = string
    default = ""    
}

variable "suffix_pip" {
    type = string
    default = ""    
}

variable "suffix_nic" {
    type = string
    default = ""    
}

variable "suffix_keyvault" {
    type = string
    default = ""    
}

variable "suffix_law" {
    type = string
    default = ""    
}

variable "suffix_app_insights" {
    type = string
    default = ""    
}

variable "suffix_fw" {
    type = string
    default = ""    
}

variable "suffix_spring" {
    type = string
    default = ""    
}

variable "suffix_appgw" {
    type = string
    default = ""    
}

variable "suffix_vm" {
    type = string
    default = ""    
}

variable "suffix_disk" {
    type = string
    default = ""    
}

