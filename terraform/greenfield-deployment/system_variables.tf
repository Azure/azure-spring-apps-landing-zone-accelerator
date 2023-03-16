# Azure Spring Apps

variable "internal_lb_svc_load_balancer_name" {
    type    = string
    default = "kubernetes-internal"
}
variable "private_dns_a_record_a_record_name" {
  type    = string
  default = "*"
}

variable "private_dns_a_record_a_record_ttl" {
  type    = number
  default = 3600
}

variable "service_principal_resource_provider_display_name" {
  type    = string
  default = "Azure Spring Apps Resource Provider"
}
