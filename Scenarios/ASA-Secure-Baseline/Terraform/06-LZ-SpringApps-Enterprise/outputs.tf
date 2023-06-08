output "spring_apps_service_name" {
  value = azurerm_spring_cloud_service.sc_enterprise.name
}

output "spring_apps_rg" {
  value = azurerm_resource_group.springapps_rg.name
}
