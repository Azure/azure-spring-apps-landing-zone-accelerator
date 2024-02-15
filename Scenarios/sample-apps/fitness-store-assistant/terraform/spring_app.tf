
locals {
  azure-metadeta      = "azure.extensions"
  spring_gateway_id   = "${data.azurerm_spring_cloud_service.sc_enterprise.id}/gateways/default"
  spring_registery_id = "${data.azurerm_spring_cloud_service.sc_enterprise.id}/serviceRegistries/default"
}
# Create ASA Apps Service
resource "azurerm_spring_cloud_app" "asa_app_service" {
  name = "assist-service"

  resource_group_name = data.azurerm_resource_group.springapps_rg.name
  service_name        = data.azurerm_spring_cloud_service.sc_enterprise.name
  is_public           = true

  identity {
    type = "SystemAssigned"
  }
}


# Create ASA Apps Deployment
resource "azurerm_spring_cloud_build_deployment" "asa_app_deployment" {
  name                = "blue"
  spring_cloud_app_id = azurerm_spring_cloud_app.asa_app_service.id
  build_result_id     = "<default>"

  quota {
    cpu    = "1"
    memory = "1Gi"
  }
}


# Create ASA Apps Deployment
resource "azurerm_spring_cloud_build_deployment" "asa_app_deployment_green" {
  name                = "green"
  spring_cloud_app_id = azurerm_spring_cloud_app.asa_app_service.id
  build_result_id     = "<default>"

  quota {
    cpu    = "1"
    memory = "1Gi"
  }
}

# Activate ASA Apps Deployment
resource "azurerm_spring_cloud_active_deployment" "asa_app_deployment_activation" {
  spring_cloud_app_id = azurerm_spring_cloud_app.asa_app_service.id
  deployment_name     = azurerm_spring_cloud_build_deployment.asa_app_deployment.name
}

# # Create Routing for Catalog Service
resource "azurerm_spring_cloud_gateway_route_config" "asa_app_catalog_routing" {
  name                    = "assist-service"
  spring_cloud_gateway_id = local.spring_gateway_id
  spring_cloud_app_id     = azurerm_spring_cloud_app.asa_app_service.id

  route {
    filters             = ["StripPrefix=0"]
    order               = 100
    predicates          = ["Path=/ai/*", "Method=POST"]
    classification_tags = ["assist-service"]
  }
}

