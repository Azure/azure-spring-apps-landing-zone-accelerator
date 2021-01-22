variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "jump_host_name" {}

variable "jump_host_vnet_name" {}

variable "jump_host_addr_prefix" {}

variable "jump_host_private_ip_addr" {}

variable "jump_host_vm_size" {}

variable "jump_host_admin_username" {}

variable "jump_host_password" {}