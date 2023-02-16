# RBAC Access for Spoke VNET
# Azure Spring Apps/Cloud Resource Provider Application ID. DO NOT Modify. This is global across all Tenants
# https://learn.microsoft.com/en-us/azure/spring-apps/how-to-create-user-defined-route-instance#add-a-role-for-an-azure-spring-apps-resource-provider

data "azuread_service_principal" "resource_provider" {
   application_id = "e8de9221-a19c-4c81-b814-fd37c6caf9d2"
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