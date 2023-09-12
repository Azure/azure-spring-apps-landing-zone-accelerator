variable "subscription_id" {
  type    = string
  default = ""
}
variable "name_prefix" {
  type    = string
  default = "entspring"
}

variable "spoke_resource_group_suffix" {
  type    = string
  default = "SPOKE"
}
variable "spring_cloud_service" {
  type    = string
  default = "spring-entspring-dev-ynyy"
}
variable "spring_cloud_resource_group_name_suffix" {
  type    = string
  default = "APPS"
}

variable "private_zones_resource_group_name_suffix" {
  type    = string
  default = "PRIVATEZONES"
}

variable "openai_CIDR" {
  type    = string
  default = "10.1.8.0/24"

}

variable "shared_rg_name_suffix" {
  type    = string
  default = "SHARED"
}
