variable "subscription_id" {
  type    = string
  default = ""
}
variable "name_prefix" {
  type    = string
  default = "springlza"
}

variable "resource_group" {
  type    = string
  default = "rg-springent-SPOKE"
}
variable "spring_cloud_service" {
  type = string
}
variable "spring_cloud_resource_group_name" {
  type    = string
  default = "rg-springent-APPS"
}

variable "private_zones_resource_group_name" {
  type    = string
  default = "rg-springent-PRIVATEZONES"
}

variable "shared_rg" {
  type    = string
  default = "rg-springent-SHARED"
}

variable "postgresql_CIDR" {
  type    = string
  default = "10.1.6.0/24"
}
variable "redis_CIDR" {
  type    = string
  default = "10.1.7.0/24"

}
