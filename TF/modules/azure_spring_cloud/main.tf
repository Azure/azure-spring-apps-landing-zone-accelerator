resource "azurerm_private_dns_zone" "spring_cloud_zone" {
  name                = "private.azuremicroservices.io"
  resource_group_name = var.resource_group_name
}

# RBAC Access for Spoke VNET

data "azuread_service_principal" "resource_provider" {
   display_name = "Azure Spring Cloud Resource Provider"
 }

resource "azurerm_role_assignment" "scowner" {
  scope                 = var.spoke_virtual_network_id
  role_definition_name = "Owner"
  principal_id = data.azuread_service_principal.resource_provider.object_id
}

resource "azurerm_application_insights" "sc_app_insights" {
  name                = "sc-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}



resource "azurerm_monitor_diagnostic_setting" "sc_diag" {
  name                        = "monitoring"
  target_resource_id          = azurerm_spring_cloud_service.sc.id
  log_analytics_workspace_id  = var.sc_law_id

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

resource "azurerm_spring_cloud_service" "sc" {
  name                = var.sc_service_name
  resource_group_name = var.sc_resource_group_name
  location            = var.location
  
  network {
    app_subnet_id                               = var.app_subnet_id
    service_runtime_subnet_id                   = var.service_runtime_subnet_id
    cidr_ranges                                 = ["10.4.0.0/16", "10.5.0.0/16", "10.3.0.1/16"]
    app_network_resource_group                  = "${var.sc_service_name}-apps-rg"
    service_runtime_network_resource_group      = "${var.sc_service_name}-runtime-rg"
  }
  
  timeouts {
      create = "60m"
      delete = "2h"
  }

  trace {
    instrumentation_key = azurerm_application_insights.sc_app_insights.instrumentation_key
  }
  depends_on = [azurerm_role_assignment.scowner]
  /*
  provisioner "local-exec" {
    # Load credentials to local environment so subsequent kubectl commands can be run
    command = <<EOS
      ascroutename=$(az network route-table list -g "${var.sc_service_name}-apps-rg" --query [].name --out tsv);
      az network route-table route create -g "${var.sc_service_name}-apps-rg" --route-table-name "$ascroutename" -n default --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address ${var.azure_fw_private_ip};
    EOS
  }*/
/*
  provisioner "local-exec" {
    # Load credentials to local environment so subsequent kubectl commands can be run
    command = <<EOS
      azurepringcloud_runtime_routetable_name=$(az network route-table list \
      --resource-group ${var.sc_service_name}_runtime_rg \
      --query [].name --out tsv);
      az network route-table route create \
      -g $azurespringcloud_app_resourcegroup_name \
      --route-table-name azurepringcloud_service_routetable_name \
      --name default \
      --address-prefix 0.0.0.0/0 \
      --next-hop-type VirtualAppliance \
      --next-hop-ip-address ${var.azure_fw_private_ip};
    EOS
  }*/
  /*
  azurespringcloud_service_resourcegroup_name=$(az spring-cloud show \
    --resource-group ${azurespringcloud_resource_group_name} \
    --name ${azurespringcloud_service} \
    --query 'properties.networkProfile.serviceRuntimeNetworkResourceGroup' --out tsv )
  */
/*
  trace {
    instrumentation_key = azurerm_application_insights.test.instrumentation_key
  }*/

  //depends_on = [azurerm_role_assignment.test]
}

/*
resource "null_resource" "set-route-table" {
  depends_on = [azurerm_spring_cloud_service.sc]
  provisioner "local-exec" {
    command = <<EOS
      ascroutename=$(az network route-table list -g "${var.sc_service_name}-apps-rg" --query [].name --out tsv);
      az network route-table route create -g "${var.sc_service_name}-apps-rg" --route-table-name "$ascroutename" -n default --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address ${var.azure_fw_private_ip};
    EOS
  }
}*/
/*
data "azurerm_resources" "runtime-route" {
  type = "Microsoft.Network/virtualNetworks/routeTables"
  resource_group_name = "${var.sc_service_name}-runtime-rg"
  
  depends_on = [azurerm_spring_cloud_service.sc]
}

data "azurerm_resources" "apps-route" {
  type = "Microsoft.Network/virtualNetworks/routeTables"
  resource_group_name = "${var.sc_service_name}-apps-rg"
  
  depends_on = [azurerm_spring_cloud_service.sc]
}
*/
/*
resource "azurerm_route" "default-route" {
  name                = "default"
  resource_group_name = "${var.sc_service_name}-runtime-rg"
  route_table_name    = data.azurerm_resources.routes.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
}*/

resource "azurerm_private_dns_zone_virtual_network_link" "hub-link" {
  name                  = "azure-spring-cloud-hub-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.spring_cloud_zone.name
  virtual_network_id    = var.hub_virtual_network_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-link" {
  name                  = "azure-spring-cloud-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.spring_cloud_zone.name
  virtual_network_id    = var.spoke_virtual_network_id
}

data "azurerm_lb" "svc_load_balancer" {
  name                = var.internal_lb_svc_load_balancer_name
  resource_group_name = "${var.sc_service_name}-runtime-rg"
  depends_on = [azurerm_spring_cloud_service.sc]
}

resource "azurerm_private_dns_a_record" "a_record" {
  name                = var.private_dns_a_record_a_record_name
  zone_name           = azurerm_private_dns_zone.spring_cloud_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = var.private_dns_a_record_a_record_ttl
  records             = ["${data.azurerm_lb.svc_load_balancer.frontend_ip_configuration[0].private_ip_address}"]
}