resource "azurerm_private_dns_zone" "spring_cloud_zone" {
  name                = "private.azuremicroservices.io"
  resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
}

# RBAC Access for Spoke VNET

data "azuread_service_principal" "resource_provider" {
   display_name = "Azure Spring Apps Resource Provider"
 }

resource "azurerm_role_assignment" "scowner" {
  scope                 = azurerm_virtual_network.spoke.id
  role_definition_name  = "Owner"
  principal_id          = data.azuread_service_principal.resource_provider.object_id
}

resource "azurerm_role_assignment" "sc_apps_route_owner" {

  scope                   = azurerm_route_table.default_apps_route.id
  role_definition_name    = "Owner"
  principal_id            = data.azuread_service_principal.resource_provider.object_id
}

resource "azurerm_role_assignment" "sc_runtime_route_owner" {

  scope                   =  azurerm_route_table.default_runtime_route.id
  role_definition_name    = "Owner"
  principal_id            = data.azuread_service_principal.resource_provider.object_id
}


resource "azurerm_log_analytics_workspace" "sc_app_insights_law" {
  name                = "${var.app_insights_prefix}-law-${random_string.random.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}



resource "azurerm_application_insights" "sc_app_insights" {
  name                = "${var.app_insights_prefix}-${random_string.random.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name
  workspace_id        = azurerm_log_analytics_workspace.sc_app_insights_law.id
  application_type    = "web"

  depends_on = [azurerm_log_analytics_workspace.sc_law]
}




resource "azurerm_private_dns_zone_virtual_network_link" "hub-link" {
  name                  = "azure-spring-cloud-hub-link"
  resource_group_name   = azurerm_resource_group.hub_sc_corp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.spring_cloud_zone.name
  virtual_network_id    = azurerm_virtual_network.hub.id 
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-link" {
  name                  = "azure-spring-cloud-spoke-link"
  resource_group_name   = azurerm_resource_group.hub_sc_corp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.spring_cloud_zone.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}





