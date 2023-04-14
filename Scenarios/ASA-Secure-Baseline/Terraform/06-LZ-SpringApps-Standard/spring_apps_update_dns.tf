resource "azurerm_private_dns_a_record" "a_record_standard" {
  
  name                = var.private_dns_a_record_a_record_name
  zone_name           = var.springapps_dnszone_name
  resource_group_name = local.private_dns_rg
  ttl                 = var.private_dns_a_record_a_record_ttl
  records             = [data.azurerm_lb.svc_load_balancer_standard.frontend_ip_configuration[0].private_ip_address]
}
