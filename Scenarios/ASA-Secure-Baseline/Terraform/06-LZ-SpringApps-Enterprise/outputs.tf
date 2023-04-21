output "spring_apps_service_name" {
  value = azurerm_spring_cloud_service.sc_enterprise.name
}

output "spring_cloud_gateway_id" {
  value = azurerm_spring_cloud_gateway.scgateway.id
}

output "sc_enterprise_registry_id" {
  value = azurerm_spring_cloud_service.sc_enterprise.service_registry_id

}
