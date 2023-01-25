# Begin Tanzu Components

resource "azurerm_spring_cloud_build_pack_binding" "appinsights-binding" {
  
  # Note: Max name 16 characters (name + builder name + builder service name max 30 chars)
  name                    = "appins-binding"
  spring_cloud_builder_id = "${azurerm_spring_cloud_service.sc_enterprise.id}/buildServices/default/builders/default"
  binding_type            = "ApplicationInsights"
  launch {
    properties = {
      sampling_percentage = "10"
    }

    secrets = {
      connection-string   = azurerm_application_insights.sc_app_insights.connection_string
    }
  }
}


# Configuration service
resource "azurerm_spring_cloud_configuration_service" "configservice" {

  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.sc_enterprise.id

}

# Gateway
resource "azurerm_spring_cloud_gateway" "scgateway" {

  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.sc_enterprise.id

  instance_count          = 2
 
}

resource "azurerm_spring_cloud_api_portal" "apiportal" {
  name                          = "default"
  spring_cloud_service_id       = azurerm_spring_cloud_service.sc_enterprise.id
  gateway_ids                   = [azurerm_spring_cloud_gateway.scgateway.id]
  https_only_enabled            = false
  public_network_access_enabled = true
  instance_count                = 1
}
