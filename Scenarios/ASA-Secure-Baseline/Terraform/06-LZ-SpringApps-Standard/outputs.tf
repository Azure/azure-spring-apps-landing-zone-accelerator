output "spring_apps_service_name" {
  value = azurerm_spring_cloud_service.sc_standard.name
}

output "spring_apps_rg" {
  value = azurerm_spring_cloud_service.sc_standard.resource_group_name
}
