variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "jump_box_name" {
    type        = string 
    description = "Jump Box Name"
}

variable "jump_box_vnet_name" { 
    type        = string 
    description = "VNET where Jump Box will be deployed"
}

variable "jump_box_addr_prefix" { 
    type        = string 
    description = "Jump Box Subnet Address Prefix"
}

variable "jump_box_private_ip_addr" {
    type        = string 
    description = "Private IP Address for Jump Box"
}

variable "jump_box_ssh_source_addr_prefixes" { 
    type        = tuple([string])
    description = "Jump Box SSH Source Addr Prefixes for NSG Rule"
}

variable "jump_box_vm_size" { 
    type        = string
    description = "Specify size of Jump Box Instance. Defaults to Standard_DS3_v2"
    default     = "Standard_DS3_v2"
}

variable "jump_box_admin_username" { 
    type        = string 
    description = "jump_box VM Username"
}

variable "jump_box_pub_key_name" { 
    type        = string 
    description = "Local public key name"
}