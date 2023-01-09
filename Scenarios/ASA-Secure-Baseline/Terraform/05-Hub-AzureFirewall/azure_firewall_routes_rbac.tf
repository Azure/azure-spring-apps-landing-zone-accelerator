# RBAC Access for Spoke VNET

data "azuread_service_principal" "resource_provider" {
   display_name = "Azure Spring Cloud Resource Provider"
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