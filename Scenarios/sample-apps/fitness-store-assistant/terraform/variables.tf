
variable "name_prefix" {
  type = string
}

variable "spoke_resource_group_name" {
  type = string

}
variable "spring_cloud_service" {
  type = string
}

variable "spring_cloud_resource_group_name" {
  type = string
}

variable "private_zones_resource_group_name" {
  type = string
}

variable "openai_CIDR" {
  type    = string
  default = "10.1.8.0/24"
}

variable "shared_rg_name" {
  type = string
}
