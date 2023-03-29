resource "azurerm_route_table" "default_apps_route" {
  name                          = "default_apps_route"
  resource_group_name           = data.azurerm_resource_group.spoke_rg.name
  location                      = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      route,tags
    ]
  }

}


resource "azurerm_route_table" "default_runtime_route" {
  name                                = "default_runtime_route"
  resource_group_name                 = data.azurerm_resource_group.spoke_rg.name
  location                            = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      route,tags
    ]
  }

}

resource "azurerm_route_table" "default_shared_route" {
  name                                = "default_shared_route"
  resource_group_name                 = data.azurerm_resource_group.spoke_rg.name
  location                            = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      route,tags
    ]
  }

}

resource "azurerm_subnet_route_table_association" "sc_app_association" {
  subnet_id      = data.azurerm_subnet.azuresbcloudapps.id
  route_table_id = azurerm_route_table.default_apps_route.id

  depends_on = [
    #Last Firewall rule is in!
    azurerm_firewall_application_rule_collection.SpringAppsRefArchApplicationRules
  ]
}

resource "azurerm_subnet_route_table_association" "sc_runtime_association" {
  subnet_id      = data.azurerm_subnet.azuresbcloudsvc.id
  route_table_id = azurerm_route_table.default_runtime_route.id

  depends_on = [
    #Last Firewall rule is in!
    azurerm_firewall_application_rule_collection.SpringAppsRefArchApplicationRules
  ]
}

resource "azurerm_subnet_route_table_association" "sc_shared_association" {
  subnet_id      = data.azurerm_subnet.snetsharedsubnet.id
  route_table_id = azurerm_route_table.default_shared_route.id

  depends_on = [
    #Last Firewall rule is in!
    azurerm_firewall_application_rule_collection.SpringAppsRefArchApplicationRules
  ]
}



## HUB Route tables



resource "azurerm_route_table" "default_hub_route" {
  provider = azurerm.hub-subscription

  name                          = "default_hub_route"
  resource_group_name           = data.azurerm_resource_group.hub_rg.name
  location                      = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
  }

  tags = var.tags 
}



