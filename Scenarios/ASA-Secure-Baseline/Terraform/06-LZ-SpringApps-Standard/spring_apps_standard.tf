
resource "azurerm_spring_cloud_service" "sc_standard" {
  
  name                = local.spring_apps_name
  resource_group_name = azurerm_resource_group.springapps_rg.name
  location            = var.location
    
  sku_name = "S0"

  # Change this to true to make your deployment zone redundant!
  # if setting to true, also consider making Azure Firewall and App Gateway Zone Redundant
  zone_redundant = false

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
 
#   depends_on = [  
#   ]

}

resource "azurerm_monitor_diagnostic_setting" "sc_diag_standard" {


  name                        = "monitoring"
  target_resource_id          = azurerm_spring_cloud_service.sc_standard.id
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
    azurerm_spring_cloud_service.sc_standard
    
  ]

}

data "azurerm_lb" "svc_load_balancer_standard" { 
  name                = var.internal_lb_svc_load_balancer_name
  resource_group_name = "${local.spring_apps_name}-runtime-rg"
  depends_on = [azurerm_spring_cloud_service.sc_standard]
}

resource "azurerm_private_dns_a_record" "a_record_standard" {
  name                = var.private_dns_a_record_a_record_name
  zone_name           = var.springapps_dnszone_name
  resource_group_name = data.azurerm_resource_group.hub_rg.name
  ttl                 = var.private_dns_a_record_a_record_ttl
  records             = [data.azurerm_lb.svc_load_balancer_standard.frontend_ip_configuration[0].private_ip_address]
}


