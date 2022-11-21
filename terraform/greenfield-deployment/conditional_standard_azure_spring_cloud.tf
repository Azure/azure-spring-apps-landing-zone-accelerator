resource "azurerm_spring_cloud_service" "sc_standard" {

  # Only execute if Standard Tier
  count = (var.skuTier == "Standard" || var.skuTier == "standard" ? 1 : 0)

  name                = local.spring_cloud_name
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name
  location            = var.location
  
  # SKU - Set to E0 if  Enterprise Tier
  sku_name = "S0"

  network {
    
    app_subnet_id                               = azurerm_subnet.azuresbcloudapps.id
    service_runtime_subnet_id                   = azurerm_subnet.azuresbcloudsvc.id
    cidr_ranges                                 = var.sc_cidr
    app_network_resource_group                  = "${local.spring_cloud_name}-apps-rg"
    service_runtime_network_resource_group      = "${local.spring_cloud_name}-runtime-rg"
  }
  
  timeouts {
      create = "60m"
      delete = "2h"
  }

  trace {
    connection_string   = azurerm_application_insights.sc_app_insights.connection_string

  }
 
  depends_on = [
    azurerm_subnet_route_table_association.sc_runtime_association,
    azurerm_subnet_route_table_association.sc_app_association,
    
    # Last FW Rule needed for Spring apps deployment
    azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowDigiCerty
  ]

}

resource "azurerm_monitor_diagnostic_setting" "sc_diag_standard" {


  # Only execute if Standard Tier
  count = (var.skuTier == "Standard" || var.skuTier == "standard" ? 1 : 0)


  name                        = "monitoring"
  target_resource_id          = azurerm_spring_cloud_service.sc_standard[0].id
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.sc_law.id

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
    azurerm_spring_cloud_service.sc_standard,
    azurerm_log_analytics_workspace.sc_law
  ]

}

data "azurerm_lb" "svc_load_balancer_standard" {
  
  # Only execute if Standard Tier
  count = (var.skuTier == "Standard" || var.skuTier == "standard" ? 1 : 0)

  name                = var.internal_lb_svc_load_balancer_name
  resource_group_name = "${local.spring_cloud_name}-runtime-rg"
  depends_on = [azurerm_spring_cloud_service.sc_standard[0]]
}

resource "azurerm_private_dns_a_record" "a_record_standard" {
  
  # Only execute if Standard Tier
  count = (var.skuTier == "Standard" || var.skuTier == "standard" ? 1 : 0)

  name                = var.private_dns_a_record_a_record_name
  zone_name           = azurerm_private_dns_zone.spring_cloud_zone.name
  resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
  ttl                 = var.private_dns_a_record_a_record_ttl
  records             = [data.azurerm_lb.svc_load_balancer_standard[0].frontend_ip_configuration[0].private_ip_address]
}


