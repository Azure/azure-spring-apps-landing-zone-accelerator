# RBAC Access for Spoke VNET
# Azure Spring Apps/Cloud Resource Provider Application ID
# https://learn.microsoft.com/en-us/azure/spring-apps/how-to-deploy-in-azure-virtual-network?tabs=azure-portal#grant-service-permission-to-the-virtual-network

data "azuread_service_principal" "resource_provider" {
   application_id = "e8de9221-a19c-4c81-b814-fd37c6caf9d2"
 }

resource "azurerm_role_assignment" "scowner" {
  scope                 = azurerm_virtual_network.spoke_vnet.id
  role_definition_name  = "Owner"
  principal_id          = data.azuread_service_principal.resource_provider.object_id
}
