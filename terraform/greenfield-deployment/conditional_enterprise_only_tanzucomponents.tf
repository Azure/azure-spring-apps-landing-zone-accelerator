# Begin Tanzu Components

resource "azurerm_spring_cloud_build_pack_binding" "appinsights-binding" {

  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)
  
  # Note: Max name 16 characters (name + builder name + builder service name max 30 chars)
  name                    = "appins-binding"
  spring_cloud_builder_id = "${azurerm_spring_cloud_service.sc_enterprise[0].id}/buildServices/default/builders/default"
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

  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.sc_enterprise[0].id

}

# Gateway
resource "azurerm_spring_cloud_gateway" "scgateway" {

  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.sc_enterprise[0].id

  instance_count          = 2
 
}

resource "azurerm_spring_cloud_api_portal" "apiportal" {

  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                          = "default"
  spring_cloud_service_id       = azurerm_spring_cloud_service.sc_enterprise[0].id
  gateway_ids                   = [azurerm_spring_cloud_gateway.scgateway[0].id]
  https_only_enabled            = false
  public_network_access_enabled = true
  instance_count                = 1
}
