# Azure provider version 

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "= 3.6.0"
    }
  }
}

provider "azurerm" {
    features {} 
}

### Create Resource group 
resource "azurerm_resource_group" "sc_corp_rg" {
    name      = var.resource_group_name
    location  = var.location
}

### Create Application Insights
resource "azurerm_application_insights" "sc_app_insights" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  depends_on = [azurerm_resource_group.sc_corp_rg]
}

### Disable the smart detection rules that get created automatically
resource "azurerm_application_insights_smart_detection_rule" "example" {
  name                    = "Slow server response time"
  application_insights_id = azurerm_application_insights.sc_app_insights.id
  enabled                 = false
}


### Create Spring Cloud Service
resource "azurerm_spring_cloud_service" "sc" {
  name                = var.sc_service_name 
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "E0" 

  # Tanzu service registry
  service_registry_enabled = true

  
  network {
    app_subnet_id                   = "/subscriptions/${var.subscription}/resourceGroups/${var.azurespringcloudvnetrg}/providers/Microsoft.Network/virtualNetworks/${var.vnet_spoke_name}/subnets/${var.app_subnet_id}"
    service_runtime_subnet_id       = "/subscriptions/${var.subscription}/resourceGroups/${var.azurespringcloudvnetrg}/providers/Microsoft.Network/virtualNetworks/${var.vnet_spoke_name}/subnets/${var.service_runtime_subnet_id}"
    cidr_ranges                     = var.sc_cidr
  }
  
  timeouts {
      create = "60m"
      delete = "2h"
  }
  
 
  depends_on = [azurerm_resource_group.sc_corp_rg]
  tags = var.tags
  
}

### Update Diags setting for Spring Cloud Service

resource "azurerm_monitor_diagnostic_setting" "sc_diag" {
  name                        = "monitoring"
  target_resource_id          = azurerm_spring_cloud_service.sc.id
  log_analytics_workspace_id = "/subscriptions/${var.subscription}/resourceGroups/${var.azurespringcloudvnetrg}/providers/Microsoft.OperationalInsights/workspaces/${var.sc_law_id}"

  log {
    category = "ApplicationConsole"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}


# Begin Tanzu Components


resource "azurerm_spring_cloud_build_pack_binding" "appinsights-binding" {
  name                    = "appinsights-binding"
  spring_cloud_builder_id = "${azurerm_spring_cloud_service.sc.id}/buildServices/default/builders/default"
  binding_type            = "ApplicationInsights"
  launch {
    properties = {
      sampling_percentage           = "10"
    }

    secrets = {
      connection-string = azurerm_application_insights.sc_app_insights.connection_string
    }
  }
}


# Configuration service
resource "azurerm_spring_cloud_configuration_service" "configservice" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.sc.id

}

# Gateway
resource "azurerm_spring_cloud_gateway" "scgateway" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.sc.id

  instance_count                = 2
 
}
