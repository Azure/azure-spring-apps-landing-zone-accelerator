variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "jump_box_name" {}

variable "jump_box_vnet_name" {}

variable "jump_box_addr_prefix" {}

variable "jump_box_private_ip_addr" {}

variable "jump_box_vm_size" {}

variable "jump_box_admin_username" {}

variable "jump_box_password" {}