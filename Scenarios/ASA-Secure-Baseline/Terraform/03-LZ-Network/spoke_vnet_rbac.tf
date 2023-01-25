# RBAC Access for Spoke VNET

data "azuread_service_principal" "resource_provider" {
   display_name = "Azure Spring Cloud Resource Provider"
 }

resource "azurerm_role_assignment" "scowner" {
  scope                 = azurerm_virtual_network.spoke_vnet.id
  role_definition_name  = "Owner"
  principal_id          = data.azuread_service_principal.resource_provider.object_id
}
