
resource "azurerm_spring_cloud_service" "sc_enterprise" {
  
  name                = local.spring_apps_name
  resource_group_name = azurerm_resource_group.springapps_rg.name
  location            = var.location

  zone_redundant = var.spring_apps_zone_redundant

  # SKU - Set to E0 if  Enterprise Tier
  sku_name = "E0"

  # Tanzu service registry - Set to true if Enterprise Tier
  service_registry_enabled = true
  build_agent_pool_size    = "S1"

  network {
    
    app_subnet_id                               = data.azurerm_subnet.azuresbcloudapps.id
    service_runtime_subnet_id                   = data.azurerm_subnet.azuresbcloudsvc.id
    cidr_ranges                                 = local.sc_cidr
    app_network_resource_group                  = "${local.spring_apps_name}-apps-rg"
    service_runtime_network_resource_group      = "${local.spring_apps_name}-runtime-rg"
  }
  
  timeouts {
      create = "60m"
      delete = "2h"
  }

  trace {
    connection_string   = azurerm_application_insights.sc_app_insights.connection_string

  }

  tags = var.tags

}

resource "azurerm_monitor_diagnostic_setting" "sc_diag_enterprise" {


  name                        = "monitoring"
  target_resource_id          = azurerm_spring_cloud_service.sc_enterprise.id
  log_analytics_workspace_id  = data.azurerm_log_analytics_workspace.sc_law.id

  log_analytics_destination_type = "AzureDiagnostics"

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

  lifecycle {
    ignore_changes = [
      log, metric
    ]
  }

  depends_on = [
    azurerm_spring_cloud_service.sc_enterprise
    
  ]

}

data "azurerm_lb" "svc_load_balancer_standard" { 
  name                = var.internal_lb_svc_load_balancer_name
  resource_group_name = "${local.spring_apps_name}-runtime-rg"
  depends_on = [azurerm_spring_cloud_service.sc_enterprise]
}



