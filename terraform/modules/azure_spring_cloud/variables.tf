variable "resource_group_name" {}
variable "location" {}
variable "app_subnet_id" {}
variable "service_runtime_subnet_id" {}
variable "hub_virtual_network_id" {}
variable "azure_fw_private_ip" {}
variable "spoke_virtual_network_id" {}
variable "sc_service_name" {}
variable "internal_lb_svc_load_balancer_name" {
    type    = string
    default = "kubernetes-internal"
}
variable "private_dns_a_record_a_record_name" {
  type    = string
  default = "*"
}
variable "sc_default_apps_route" {}
variable "sc_default_runtime_route" {}

variable "private_dns_a_record_a_record_ttl" {
  type    = number
  default = 3600
}
variable "sc_law_id" {}

variable "sc_cidr" {}

variable "app_insights_name" {}
