resource "azurerm_private_dns_zone" "spring_cloud_zone" {
  name                = "private.azuremicroservices.io"
  resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
}

# RBAC Access for Spoke VNET

data "azuread_service_principal" "resource_provider" {
   display_name = "Azure Spring Cloud Resource Provider"
 }

resource "azurerm_role_assignment" "scowner" {
  scope                 = azurerm_virtual_network.spoke.id
  role_definition_name  = "Owner"
  principal_id          = data.azuread_service_principal.resource_provider.object_id
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

resource "azurerm_application_insights" "sc_app_insights" {
  name                = "${var.app_insights_prefix}-${random_string.random.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name
  application_type    = "web"
}





resource "azurerm_spring_cloud_service" "sc" {
  name                = local.spring_cloud_name
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name
  location            = var.location
  
  # SKU - Set to E0 if  Enterprise Tier
  sku_name = ( var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? "E0" : "S0" )

  # Tanzu service registry - Set to true if Enterprise Tier
  service_registry_enabled = ( var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? true : false )
  build_agent_pool_size    = "S1"

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
    azurerm_subnet_route_table_association.sc_app_association
  ]

}

resource "azurerm_monitor_diagnostic_setting" "sc_diag" {
  name                        = "monitoring"
  target_resource_id          = azurerm_spring_cloud_service.sc.id
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
    azurerm_spring_cloud_service.sc,
    azurerm_log_analytics_workspace.sc_law
  ]

}

resource "azurerm_private_dns_zone_virtual_network_link" "hub-link" {
  name                  = "azure-spring-cloud-hub-link"
  resource_group_name   = azurerm_resource_group.hub_sc_corp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.spring_cloud_zone.name
  virtual_network_id    = azurerm_virtual_network.hub.id 
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-link" {
  name                  = "azure-spring-cloud-spoke-link"
  resource_group_name   = azurerm_resource_group.hub_sc_corp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.spring_cloud_zone.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}

data "azurerm_lb" "svc_load_balancer" {
  name                = var.internal_lb_svc_load_balancer_name
  resource_group_name = "${local.spring_cloud_name}-runtime-rg"
  depends_on = [azurerm_spring_cloud_service.sc]
}

resource "azurerm_private_dns_a_record" "a_record" {
  name                = var.private_dns_a_record_a_record_name
  zone_name           = azurerm_private_dns_zone.spring_cloud_zone.name
  resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
  ttl                 = var.private_dns_a_record_a_record_ttl
  records             = [data.azurerm_lb.svc_load_balancer.frontend_ip_configuration[0].private_ip_address]
}


